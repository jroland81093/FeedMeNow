//
//  YelpClient.m
//  FeedMeNow
//
//  Created by Jamey Roland on 7/7/14.
//  Copyright (c) 2014 Jamey Roland. All rights reserved.
//

#import "YelpClient.h"

@implementation YelpClient

//RETURN CATEGORIES
#define kYelpCategories = @"categories"
#define kYelpPhoneNumber = @"display_phone"
#define kYelpIsClosed = @"is_closed"
#define kYelpLocation = @"location"
#define kYelpLocation_Address = @"address"
#define kYelpLocation_City = @"city"
#define kYelpCoordinate = @"coordinate"
#define kYelpCoordinate_Latitude = @"latitude"
#define kYelpCoordinate_Longitude = @"longitude"

- (id)initWithCredentials
{
    NSURL *baseURL = [NSURL URLWithString:@"http://api.yelp.com/v2/"];
    NSString * const kYelpConsumerKey = @"FMyQC-aJn97X4ZRoIK8iQQ";
    NSString * const kYelpConsumerSecret = @"NQEe25XYWdwiS6EySs4IOxfK7eY";
    NSString * const kYelpToken = @"BUWrBBt699SGyAUlNIZF--1VPGD8YFBg";
    NSString * const kYelpTokenSecret = @"NLY8qP9XatNTpp64XqsFBZgikjM";
    
    self = [super initWithBaseURL:baseURL consumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret];
    if (self) {
        BDBOAuthToken *token = [BDBOAuthToken tokenWithToken:kYelpToken secret:kYelpTokenSecret expiration:nil];
        [self.requestSerializer saveAccessToken:token];
    }
    return self;
}

- (AFHTTPRequestOperation *)searchWithTerm:(NSString *)term success:(void (^)(AFHTTPRequestOperation *operation, id response))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api
    NSDictionary *parameters = @{@"term": term, @"location" : @"San Francisco"};
    
    return [self GET:@"search" parameters:parameters success:success failure:failure];
}

@end
