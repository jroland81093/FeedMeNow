//
//  OrdrClient.h
//  FeedMeNow
//
//  Created by Jamey Roland on 7/12/14.
//  Copyright (c) 2014 Jamey Roland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import <CoreLocation/CoreLocation.h>
#import <FlatUIKit.h>
#import "Address.h"
#import "LoadingViewController.h"

@interface OrdrClient : NSObject <NSURLConnectionDelegate>

- (id)initWithLoadingViewController: (LoadingViewController *)loadingViewController;

//API Functions
- (Address *)addressNearCoordinate: (CLLocationCoordinate2D)coordinate;
- (BOOL)findRestaurantsNearCoordinate: (CLLocationCoordinate2D)coordinate;
- (void) generateAllEntreesToArray: (NSMutableArray *)array;
- (void) generateAllEntreesToDictionary: (NSMutableDictionary *)dictionary;

@property (atomic) NSUInteger numCompletedResponses;

//API Keys and Requests
#define ORDER_KEY @"QwueeaKvypUVCC2j4KqGQJYfzvXU6Zb4wYeR13ZTsV0"
#define MASHAPE_KEY @"yd0ET5PqwnmshXdvb4WhY7XqgMdyp1sJ1CojsnnkFfDK1IO69U"
#define HTTP_REQUEST_GET @"GET"
#define MASHAPE_REQUEST_HEADER @"X-Mashape-Key"
#define ORDRIN_REQUEST_HEADER @"X-NAAMA-CLIENT-AUTHENTICATION"

//Fixed Strings for Location API Requests
#define K_STREET_NUMBER @"street_number"
#define K_STREET_NAME @"street_name"
#define K_CITY_NAME @"city"
#define K_ZIPCODE @"zip"

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
