//
//  ParsingOperation.h
//  FeedMeNow
//
//  Created by James Roland on 8/3/14.
//  Copyright (c) 2014 Jamey Roland. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParsingOperation : NSOperation

- (id)initWithData: (NSData *)responseData withRestaurantDictionary:(NSMutableDictionary *)restaurantDictionary withSuggestionArray:(NSMutableArray *)suggestionArray;

- (id)initWithData: (NSData *)responseData withRestaurantDictionary:(NSMutableDictionary *)restaurantDictionary withSuggestionDictionary:(NSMutableDictionary *)suggestionDictionary;

//Fixed Strings for Restaurant API Requests
#define K_RESTAURANT_IS_DELIVERING @"is_delivering"
#define K_RESTAURANT_ID @"id"
#define K_RESTAURANT_NAME @"na"
#define K_RESTAURANT_PHONE @"cs_phone"

#define K_RESTAURANT_MENU @"menu.children"
#define K_RESTAURANT_MENU_ID @"restaurant_id"
#define K_RESTAURANT_MENU_NAME @"name"
#define K_RESTAURANT_MENU_IS_ORDERABLE @"is_orderable"

@end
