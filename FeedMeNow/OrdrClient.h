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
#import "Address.h"
#import "HomeViewController.h"

@interface OrdrClient : NSObject <NSURLConnectionDelegate>

- (id)initWithViewController: (HomeViewController *)viewController;
- (Address *)addressNearCoordinate: (CLLocationCoordinate2D)coordinate;
- (BOOL)findRestaurantsNearCoordinate: (CLLocationCoordinate2D)coordinate;
- (void)generateAllEntrees;

@property (nonatomic, strong) NSMutableArray *deliverableRestaurants;
@property (atomic) NSUInteger numCompletedRequests;

@end
