//
//  LoadingViewController.h
//  FeedMeNow
//
//  Created by Jamey Roland on 7/29/14.
//  Copyright (c) 2014 Jamey Roland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MACircleProgressIndicator.h>
@interface LoadingViewController : UIViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet MACircleProgressIndicator *progressIndicator;

- (void)generateUserInterface;
//Used as a callback function after API responses.

@end
