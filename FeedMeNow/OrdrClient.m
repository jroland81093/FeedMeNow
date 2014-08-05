//
//  OrdrClient.m
//  FeedMeNow
//
//  Created by Jamey Roland on 7/12/14.
//  Copyright (c) 2014 Jamey Roland. All rights reserved.
//

#import "OrdrClient.h"
#import "Restaurant.h"
#import "Suggestion.h"
#import "ParsingOperation.h"

@implementation OrdrClient
{
    //Auxilary classes
    const NSString *ordrKey;
    const NSString *mashapeKey;
    LoadingViewController *delegate;
    NSOperationQueue *operationQueue;
    
    //Containers
    NSMutableArray *deliverableRestaurantsIDs;
    NSMutableDictionary *deliverableRestaurants;
    NSArray *nonEntreesNames;
    
    BOOL presentedViewController;
}

- (id)initWithLoadingViewController: (LoadingViewController *)loadingViewController;
{
    self = [super init];
    if (self)
    {
        ordrKey = ORDER_KEY ;
        mashapeKey= MASHAPE_KEY;
        delegate = loadingViewController;
        operationQueue = [[NSOperationQueue alloc] init];
        
        deliverableRestaurants = [[NSMutableDictionary alloc] init];
        deliverableRestaurantsIDs = [[NSMutableArray alloc] init];
        
        self.numCompletedResponses = 0;
        presentedViewController = NO;
    }
    return self;
}

#pragma mark - Get nearby restaurants

- (Address *)addressNearCoordinate: (CLLocationCoordinate2D)coordinate;
    //Returns an address given a 2D coordinate user location
{
    //Set up URL Request
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://montanaflynn-geocode-location-information.p.mashape.com/reverse?latitude=%f&longitude=%f", coordinate.latitude, coordinate.longitude]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:HTTP_REQUEST_GET];
    [request addValue:[NSString stringWithFormat:@"%@", mashapeKey] forHTTPHeaderField:MASHAPE_REQUEST_HEADER];
    
    //Set up response and send request
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %i", url, [responseCode statusCode]);
        return nil;
    }
    else
    {
        NSJSONSerialization *jsonObject = [NSJSONSerialization JSONObjectWithData:oResponseData options:NSJSONReadingMutableContainers error:nil];
        
        //Set up user address from JSON Response
        Address *userAddress = [[Address alloc] init];
        NSString *address = [NSString stringWithFormat:@"%@ %@",[jsonObject valueForKey:K_STREET_NUMBER], [jsonObject valueForKey:K_STREET_NAME]];
        NSString *city = [NSString stringWithFormat:@"%@", [jsonObject valueForKey:K_CITY_NAME]];
        [userAddress setStreetAddress:[address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [userAddress setZip:[NSString stringWithFormat:@"%@", [jsonObject valueForKey:K_ZIPCODE]]];
        [userAddress setCity:[city stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSLog(@"Successfully found user address");
        return userAddress;
    }
}

- (BOOL)findRestaurantsNearCoordinate: (CLLocationCoordinate2D)coordinate
//Finds all restaurants near an address.
{
    Address *userAddress = [self addressNearCoordinate:coordinate];
    if (userAddress)
    {
        //Update user interface
        [[delegate progressIndicator] setColor: [UIColor belizeHoleColor]];
        [[delegate progressLabel] setText:@"Finding nearby restaurants..."];
        
        //Set up URL Request
        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://r-test.ordr.in/dl/ASAP/%@/%@/%@", [userAddress zip], [userAddress city], [userAddress streetAddress]]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setHTTPMethod:HTTP_REQUEST_GET];
        [request addValue:[NSString stringWithFormat:@"id=\"%@\", version=\"1\"", ordrKey] forHTTPHeaderField:ORDRIN_REQUEST_HEADER];
        
        //Set up response and send request
        NSError *error = [[NSError alloc] init];
        NSHTTPURLResponse *responseCode = nil;
        NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
        if([responseCode statusCode] != 200){
            NSLog(@"Error getting %@, HTTP status code %i", url, [responseCode statusCode]);
            return NO;
        }
        else
        {
            NSArray *allRestaurants = [NSJSONSerialization JSONObjectWithData:oResponseData options:NSJSONReadingMutableContainers error:nil];
            
            //Set up restaurants from JSON Response
            for (NSDictionary *restaurant in allRestaurants)
            {
                if ([[restaurant valueForKey:K_RESTAURANT_IS_DELIVERING] integerValue])
                {
                    NSNumber *restaurantIDNumber = [restaurant valueForKey:K_RESTAURANT_ID];
                    NSString *restaurantID = [NSString stringWithFormat:@"%@", restaurantIDNumber];
                    
                    Restaurant *deliveryRestaurant = [[Restaurant alloc] init];
                    [deliveryRestaurant setRestaurantID:restaurantID];
                    [deliveryRestaurant setName:[restaurant valueForKey:K_RESTAURANT_NAME]];
                    [deliveryRestaurant setPhoneNumber:[restaurant valueForKey:K_RESTAURANT_PHONE]];
                    
                    [deliverableRestaurantsIDs addObject:restaurantID];
                    [deliverableRestaurants setValue:deliveryRestaurant forKey:restaurantID];
                }
            }
            NSLog(@"Successfully found nearby restaurants");
            return YES;
        }
    }
    return NO;
}


#pragma mark - Get entrees of restaurants

- (void) generateAllEntreesToDictionary: (NSMutableDictionary *)dictionary;
//Find and store all deliverables nearby into the singleton instance.
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:HTTP_REQUEST_GET];
    [request addValue:[NSString stringWithFormat:@"id=\"%@\", version=\"1\"", ordrKey] forHTTPHeaderField:ORDRIN_REQUEST_HEADER];
    
    if ([deliverableRestaurantsIDs count] == 0)
    {
        [self presentLocationError];
    }
    
    for (NSString *restaurantID in deliverableRestaurantsIDs)
    {
        //Setup URL
        Restaurant *restaurant = [deliverableRestaurants objectForKey:restaurantID];
        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://r-test.ordr.in/rd/%@", [restaurant restaurantID]]];
        [request setURL:url];
        
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        [dictionary setValue:arr forKey:[restaurant restaurantID]];
        
        //Send operation and parse upon completion.
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            ParsingOperation *parsingOperation = [[ParsingOperation alloc] initWithData:responseObject withRestaurantDictionary:deliverableRestaurants withSuggestionDictionary:dictionary];
            [operationQueue addOperation:parsingOperation];
            
            //Log and present UI when necessary.
            self.numCompletedResponses++;
            NSLog(@"%d/%d", self.numCompletedResponses, [deliverableRestaurantsIDs count]);
            if (self.numCompletedResponses == [deliverableRestaurantsIDs count])
            {
                [delegate setRestaurantIDs:deliverableRestaurantsIDs];
                [delegate generateUserInterface];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"FAILURE ON MAIN THREAD");
            self.numCompletedResponses++;
        }];
        [operationQueue addOperation:operation];
    }
}


#pragma mark - Helper functions
- (void) presentLocationError
//User didn't allow for location services
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Couldn't find any open restaurants" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    [alertView show];
    [[delegate progressLabel] setText:@"No open restaurants"];
}
@end
