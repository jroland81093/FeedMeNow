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
        nonEntreesNames = @[@"water", @"coke", @"sprite", @"soda", @"juice", @"drink", @"fountain", @"milk", @"brown rice", @"white rice", @"lemonade"];
        
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
    
    for (NSString *restaurantID in deliverableRestaurantsIDs)
    {
        Restaurant *restaurant = [deliverableRestaurants objectForKey:restaurantID];
        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://r-test.ordr.in/rd/%@", [restaurant restaurantID]]];
        [request setURL:url];
        
        
        //Send operation and parse upon completion.
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            //
            ParsingOperation *parsingOperation = [[ParsingOperation alloc] initWithData:responseObject usingRestaurants:deliverableRestaurants usingSuggestionsDictionary:dictionary withNonEntreeNames:nonEntreesNames];
            [operationQueue addOperation:parsingOperation];
            
            self.numCompletedResponses++;
            if (self.numCompletedResponses == [deliverableRestaurantsIDs count])
            {
                [delegate generateUserInterface];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"FAILURE ON MAIN THREAD");
            self.numCompletedResponses++;
        }];
        [operationQueue addOperation:operation];
    }
}


- (void) generateAllEntreesToArray: (NSMutableArray *)array;
    //Find and store all deliverables nearby into the singleton instance.
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:HTTP_REQUEST_GET];
    [request addValue:[NSString stringWithFormat:@"id=\"%@\", version=\"1\"", ordrKey] forHTTPHeaderField:ORDRIN_REQUEST_HEADER];

    for (NSString *restaurantID in deliverableRestaurantsIDs)
    {
        Restaurant *restaurant = [deliverableRestaurants objectForKey:restaurantID];
        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://r-test.ordr.in/rd/%@", [restaurant restaurantID]]];
        [request setURL:url];
        
        
        //Send operation and parse upon completion.
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            //
            ParsingOperation *parsingOperation = [[ParsingOperation alloc] initWithData:responseObject usingRestaurants:deliverableRestaurants usingSuggestions:array withNonEntreeNames:nonEntreesNames];
            [operationQueue addOperation:parsingOperation];
            
            self.numCompletedResponses++;
            if (self.numCompletedResponses == [deliverableRestaurantsIDs count])
            {
                [delegate generateUserInterface];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"FAILURE ON MAIN THREAD");
            self.numCompletedResponses++;
        }];
        [operationQueue addOperation:operation];
    }
}
     /*
    for (NSString *restaurantID in deliverableRestaurantsIDs)
    {
        //Set up URL for each restaurant
        Restaurant *restaurant = [deliverableRestaurants objectForKey:restaurantID];
        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://r-test.ordr.in/rd/%@", [restaurant restaurantID]]];
        [request setURL:url];
     
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@", [NSThread currentThread]);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", [NSThread currentThread]);
        }];
        [operationQueue addOperation:operation];
        //Send out the requests asynchronously and concurrently.

    
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
         
            NSDictionary *allData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSArray *entireMenu = [allData valueForKeyPath:K_RESTAURANT_MENU];
            NSString *idOuter = [NSString stringWithFormat:@"%@",[allData valueForKey:K_RESTAURANT_MENU_ID]];
             //Used for multithreading purpose
            if (![entireMenu isKindOfClass:[NSNull class]])
            {
                //Add to deliverable restaurants
                for (NSArray *category in entireMenu)
                {
                    if (![category isKindOfClass:[NSNull class]])
                    {
                        for (NSObject *entree in category)
                        {
                            if (![entree isKindOfClass:[NSNull class]])
                            {
                                if ([[entree valueForKey:K_RESTAURANT_MENU_IS_ORDERABLE] integerValue])
                                {
                                    NSString *entreeName = [entree valueForKey:K_RESTAURANT_MENU_NAME];
                                    if ([self isValidEntree:entreeName])
                                    {
                                        //Ensure multithreading didn't overwrite
                                        NSString *idInner = [NSString stringWithFormat:@"%@", [[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil] valueForKey:K_RESTAURANT_MENU_ID]];
                                        if ([idOuter isEqualToString:idInner])
                                        {
                                            //Add a suggestion to the passed in array.
                                            Restaurant *addedRestaurant = [deliverableRestaurants valueForKey:idInner];
                                            Suggestion *suggestion = [[Suggestion alloc] init];
                                            
                                            [suggestion setRestaurantName:[addedRestaurant name]];
                                            [suggestion setEntreeName:entreeName];
                                            [suggestion setPhoneNumber:[addedRestaurant phoneNumber]];
                                            //Dictionary of arrays
                                                //Restaurant -> Array of suggestions.
                                            [array addObject:suggestion];
                                            self.numCompletedSuggestions++;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            self.numCompletedRequests++;
            NSLog(@"Thread: %@", [NSThread currentThread]);
            NSLog(@"Main thread: %@", [NSThread mainThread]);
            if (!presentedViewController)
            {
                presentedViewController = YES;
                [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                    [delegate generateUserInterface];
                }];
            }
            if (self.numCompletedRequests == [deliverableRestaurantsIDs count])
            {
                [operationQueue cancelAllOperations];
                NSLog(@"DONE");
            }
             
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Operation Queue cancelled");
        }];
        [operationQueue addOperation:operation];
      
    }*/


#pragma mark - Helper Functions
- (NSString *)isValidEntree:(NSString *)entree
{
    for (NSString *nonEntree in nonEntreesNames)
        //Get rid of bad substrings
    {
        if ([entree rangeOfString:nonEntree options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            return nil;
        }
    }
    /*
    NSRange entireRange = NSMakeRange(0, [entree length]);
    NSMutableString *returnString;
    NSError *error = NULL;
     */

    //Regular expression to sanitize
    return entree;
}


@end
