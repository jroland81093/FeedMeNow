//
//  OrdrClient.m
//  FeedMeNow
//
//  Created by Jamey Roland on 7/12/14.
//  Copyright (c) 2014 Jamey Roland. All rights reserved.
//

#import "OrdrClient.h"
#import "Restaurant.h"

#define HTTP_REQUEST_GET @"GET"
#define MASHAPE_KEY @"X-Mashape-Key"


@implementation OrdrClient
{
    const NSString *ordrKey;
    const NSString *mashapeKey;
    NSOperationQueue *operationQueue;
    NSArray *nonEntreesNames;
    HomeViewController *parent;
}
@synthesize deliverableRestaurants;

- (id)initWithViewController: (HomeViewController *)viewController
{
    self = [super init];
    if (self)
    {
        parent = viewController;
        ordrKey = @"QwueeaKvypUVCC2j4KqGQJYfzvXU6Zb4wYeR13ZTsV0";
        mashapeKey= @"yd0ET5PqwnmshXdvb4WhY7XqgMdyp1sJ1CojsnnkFfDK1IO69U";
        deliverableRestaurants = [[NSMutableArray alloc] init];
        operationQueue = [[NSOperationQueue alloc] init];
        self.numCompletedRequests = 0;
        nonEntreesNames = @[@"water", @"coke", @"sprite", @"soda", @"juice", @"drink", @"fountain"];
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
    [request addValue:[NSString stringWithFormat:@"%@", mashapeKey] forHTTPHeaderField:MASHAPE_KEY];
    
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
        Address *userAddress = [[Address alloc] init];
        
        NSString *address = [NSString stringWithFormat:@"%@ %@",[jsonObject valueForKey:@"street_number"], [jsonObject valueForKey:@"street_name"]];
        NSString *city = [NSString stringWithFormat:@"%@", [jsonObject valueForKey:@"city"]];
        [userAddress setStreetAddress:[address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [userAddress setZip:[NSString stringWithFormat:@"%@", [jsonObject valueForKey:@"zip"]]];
        [userAddress setCity:[city stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        return userAddress;
    }
}

- (BOOL)findRestaurantsNearCoordinate: (CLLocationCoordinate2D)coordinate
//Finds all restaurants near an address.
{
    //Set up Request
    Address *userAddress = [self addressNearCoordinate:coordinate];
    if (userAddress)
    {
        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://r-test.ordr.in/dl/ASAP/%@/%@/%@", [userAddress zip], [userAddress city], [userAddress streetAddress]]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setHTTPMethod:HTTP_REQUEST_GET];
        [request addValue:[NSString stringWithFormat:@"id=\"%@\", version=\"1\"", ordrKey] forHTTPHeaderField:@"X-NAAMA-CLIENT-AUTHENTICATION"];
        
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
            for (NSDictionary *restaurant in allRestaurants)
            {
                if ([[restaurant valueForKey:@"is_delivering"] integerValue])
                {
                    Restaurant *deliveryRestaurant = [[Restaurant alloc] init];
                    [deliveryRestaurant setName:[restaurant valueForKey:@"na"]];
                    [deliveryRestaurant setPhoneNumber:[restaurant valueForKey:@"cs_phone"]];
                    [deliveryRestaurant setRestaurantID:[restaurant valueForKey:@"id"]];
                    [deliverableRestaurants addObject:deliveryRestaurant];
                }
            }
            return YES;
        }
    }

    return NO;
}


#pragma mark - Get entrees of restaurants
- (void) generateAllEntrees
    //Find and store all deliverables nearby into the singleton instance.
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:HTTP_REQUEST_GET];
    [request addValue:[NSString stringWithFormat:@"id=\"%@\", version=\"1\"", ordrKey] forHTTPHeaderField:@"X-NAAMA-CLIENT-AUTHENTICATION"];
    
    for (Restaurant *restaurant in deliverableRestaurants)
    {
        //Set up URL for each restaurant
        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://r-test.ordr.in/rd/%@", [restaurant restaurantID]]];
        [request setURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            // Print the response body in text
            NSArray *allMenu = [[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil] valueForKeyPath:@"menu.children"];
            if (![allMenu isKindOfClass:[NSNull class]])
            {
                for (NSArray *category in allMenu)
                {
                    if (![category isKindOfClass:[NSNull class]])
                    {
                        for (NSObject *entree in category)
                        {
                            if (![entree isKindOfClass:[NSNull class]])
                            {
                                if ([[entree valueForKey:@"is_orderable"] integerValue])
                                {
                                    NSString *entreeName = [entree valueForKey:@"name"];
                                    if ([self isValidEntree:entreeName])
                                    {
                                        [[restaurant orderableEntrees] addObject:entreeName];
                                    }
                                }
                            }
                        }
                    }
                }
            }
            self.numCompletedRequests++;
            if (self.numCompletedRequests == [deliverableRestaurants count])
            {
                [[parent activityIndicator] stopAnimating];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[self deliverableRestaurants] removeObjectIdenticalTo:restaurant];
        }];
        [operationQueue addOperation:operation];
        /*
        [operationQueue addOperationWithBlock:^{
            NSURL CONNECTION
            [NSURLConnection sendAsynchronousRequest:request queue:operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                NSLog(@"response");
                if (connectionError || data.length == 0)
                {
                    NSLog(@"Error");
                }
                else
                {
                    NSArray *allMenu = [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil] valueForKeyPath:@"menu.children"];
                    if (![allMenu isKindOfClass:[NSNull class]])
                    {
                        for (NSArray *category in allMenu)
                        {
                            if (![category isKindOfClass:[NSNull class]])
                            {
                                for (NSObject *entree in category)
                                {
                                    if (![entree isKindOfClass:[NSNull class]])
                                    {
                                        if ([[entree valueForKey:@"is_orderable"] integerValue])
                                        {
                                            NSString *entreeName = [entree valueForKey:@"name"];
                                            if ([self isValidEntree:entreeName])
                                            {
                                                [[restaurant orderableEntrees] addObject:entreeName];
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    self.numCompletedRequests++;
                    NSLog(@"Request %d", self.numCompletedRequests);
                }
            }];
         
        }];*/
    }
}

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
    return entree;
}



@end
