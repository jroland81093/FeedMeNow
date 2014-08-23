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
    NSString *restaurantName;
    NSString *restaurantID;
    
    NSMutableDictionary *suggestionRestaurantIDs; //rid -> restaurant
    NSMutableDictionary *allSuggestions; //rid -> [suggestion]
    
    NSArray *nonEntreeNames;
}

- (id)initWithData: (NSData *)responseData withRestaurantDictionary:(NSMutableDictionary *)restaurantDictionary withSuggestionDictionary:(NSMutableDictionary *)suggestionDictionary;
{
    self = [super init];
    if (self)
    {
        
        
        entireMenu = [[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil] valueForKeyPath:K_RESTAURANT_MENU];
        restaurantName = [[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil] valueForKeyPath:K_RESTAURANT_MENU_NAME];
        restaurantID = [[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil] valueForKeyPath:K_RESTAURANT_MENU_ID];
        
        suggestionRestaurantIDs = restaurantDictionary;
        allSuggestions = suggestionDictionary;
        nonEntreeNames = @[@"water", @"coke", @"sprite", @"soda", @"juice", @"drink", @"fountain", @"milk", @"brown rice", @"white rice", @"lemonade"];
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
                                //Add a suggestion to the passed in dictionary
                                Restaurant *addedRestaurant = [suggestionRestaurantIDs valueForKey:restaurantID];
                                Suggestion *suggestion = [[Suggestion alloc] init];
                                [suggestion setRestaurantName:[addedRestaurant name]];
                                [suggestion setEntreeName:entreeName];
                                [suggestion setPhoneNumber:[addedRestaurant phoneNumber]];
                                
                                NSMutableArray *restaurantEntrees = [allSuggestions valueForKey:restaurantID];
                                [restaurantEntrees addObject:suggestion];
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
    //Filter out numbers
    NSRegularExpression *expressionWithoutNumberPrefix = [NSRegularExpression regularExpressionWithPattern:@"^[0-9]*[.)] " options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *numberPrefixMatches = [expressionWithoutNumberPrefix matchesInString:entree options:NSMatchingReportCompletion range:NSMakeRange(0, entree.length)];
    for (NSTextCheckingResult *result in numberPrefixMatches)
    {
        [entree stringByReplacingCharactersInRange:result.range withString:@""];
    }
    
    for (NSString *nonEntree in nonEntreeNames)
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
