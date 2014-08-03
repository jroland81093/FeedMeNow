//
//  ParsingOperation.h
//  FeedMeNow
//
//  Created by James Roland on 8/3/14.
//  Copyright (c) 2014 Jamey Roland. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParsingOperation : NSOperation

- (id)initWithData: (NSData *)responseData usingRestaurants:(NSDictionary *)restaurants usingSuggestions: (NSMutableArray *)suggestions withNonEntreeNames: (NSArray *)badEntreeNames;

- (id)initWithData: (NSData *)responseData usingRestaurants:(NSDictionary *)restaurants usingSuggestionsDictionary: (NSMutableDictionary *)suggestions withNonEntreeNames: (NSArray *)badEntreeNames;

//API Keys and Requests
#define ORDER_KEY @"QwueeaKvypUVCC2j4KqGQJYfzvXU6Zb4wYeR13ZTsV0"
#define MASHAPE_KEY @"yd0ET5PqwnmshXdvb4WhY7XqgMdyp1sJ1CojsnnkFfDK1IO69U"
#define HTTP_REQUEST_GET @"GET"
#define ORDRIN_REQUEST_HEADER @"X-NAAMA-CLIENT-AUTHENTICATION"


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
