//
//  ParsingOperation.m
//  FeedMeNow
//
//  Created by James Roland on 8/3/14.
//  Copyright (c) 2014 Jamey Roland. All rights reserved.
//

#import "ParsingOperation.h"
#import "Restaurant.h"
#import "Suggestion.h"

@implementation ParsingOperation
{
    NSArray *entireMenu;
    NSString *restaurantID;
    
    NSDictionary *deliverableRestaurants;
    NSMutableArray *suggestionArray;
    NSArray *nonEntreeNames;
}

- (id)initWithData: (NSData *)responseData usingRestaurants:(NSDictionary *)restaurants usingSuggestions: (NSMutableArray *)suggestions withNonEntreeNames: (NSArray *)badEntreeNames
{
    self = [super init];
    if (self) {
        //Pull information from data
        NSDictionary *allData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        restaurantID = [NSString stringWithFormat:@"%@", [[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil] valueForKey:K_RESTAURANT_MENU_ID]];
        entireMenu = [allData valueForKeyPath:K_RESTAURANT_MENU];
        
        //Load the arrray with data and bad entree names.
        deliverableRestaurants = restaurants;
        suggestionArray = suggestions;
        nonEntreeNames = badEntreeNames;
    }
    return self;
}
- (void)start
{
    if (![entireMenu isKindOfClass:[NSNull class]])
    {
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
                                //Add a suggestion to the passed in array.
                                Restaurant *addedRestaurant = [deliverableRestaurants valueForKey:restaurantID];
                                Suggestion *suggestion = [[Suggestion alloc] init];
                                [suggestion setRestaurantName:[addedRestaurant name]];
                                [suggestion setEntreeName:entreeName];
                                [suggestion setPhoneNumber:[addedRestaurant phoneNumber]];
                                
                                //[suggestionArray addObject:suggestion];
                                //ADD TO DICTIONARY INSTEAD.
                            }
                        }
                    }
                }
            }
        }
    }
}

#pragma mark - NSURLDelegate method.

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"Response: %@", response);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection error: %@", error);
}

#pragma mark - Helper function
- (NSString *)isValidEntree:(NSString *)entree
{
    for (NSString *nonEntree in nonEntreeNames)
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
