//
//  Restaurant.h
//  FeedMeNow
//
//  Created by Jamey Roland on 7/13/14.
//  Copyright (c) 2014 Jamey Roland. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Restaurant : NSObject <NSCoding>
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *restaurantID;

@end
