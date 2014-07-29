//
//  HomeViewController.h
//  FeedMeNow
//
//  Created by Jamey Roland on 7/7/14.
//  Copyright (c) 2014 Jamey Roland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <FlatUIKit.h>
#import <FBGlowLabel.h>
#import <HZActivityIndicatorView.h>
#import <MACircleProgressIndicator.h>

@interface HomeViewController : UIViewController <CLLocationManagerDelegate>

-(void) updateUserInterface;

@property (strong, nonatomic) IBOutlet FUIButton *generateFoodButton;
@property (strong, nonatomic) IBOutlet MACircleProgressIndicator *MACircleIndicatorView;
@property (strong, nonatomic) IBOutlet FBGlowLabel *entreeLabel;
@property (strong, nonatomic) IBOutlet FBGlowLabel *restaurantLabel;

@end
