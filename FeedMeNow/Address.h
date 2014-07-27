//
//  Address.h
//  FeedMeNow
//
//  Created by Jamey Roland on 7/13/14.
//  Copyright (c) 2014 Jamey Roland. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Address : NSObject
@property (nonatomic, strong) NSString *streetAddress;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *zip;

@end
