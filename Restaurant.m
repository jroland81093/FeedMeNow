//
//  Restaurant.m
//  FeedMeNow
//
//  Created by Jamey Roland on 7/13/14.
//  Copyright (c) 2014 Jamey Roland. All rights reserved.
//

#import "Restaurant.h"

#define NAME @"Name"
#define PHONE @"PhoneNumber"
#define RESTAURANTID @"RestaurantID"


@implementation Restaurant

@synthesize name, phoneNumber, restaurantID;
- (id)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        name = [aDecoder decodeObjectForKey:NAME];
        phoneNumber = [aDecoder decodeObjectForKey:PHONE];
        restaurantID = [aDecoder decodeObjectForKey:RESTAURANTID];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:NAME];
    [aCoder encodeObject:self.phoneNumber forKey:PHONE];
    [aCoder encodeObject:self.restaurantID forKey:RESTAURANTID];
}

@end
