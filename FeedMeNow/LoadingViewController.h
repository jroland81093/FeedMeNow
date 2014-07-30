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
#import <FBGlowLabel.h>

@interface LoadingViewController : UIViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet MACircleProgressIndicator *progressIndicator;
@property (strong, nonatomic) IBOutlet FBGlowLabel *progressLabel;


@property (strong, nonatomic) NSMutableArray *diningSuggestions;

- (void)generateUserInterface;
//Used as a callback function after API responses.

@end
