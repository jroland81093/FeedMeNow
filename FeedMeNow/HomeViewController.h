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

@interface HomeViewController : UIViewController <CLLocationManagerDelegate>

-(void) updateUserInterface;

@property (strong, nonatomic) IBOutlet UIButton *generateFoodButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *entreeLabel;
@property (strong, nonatomic) IBOutlet UILabel *restaurantLabel;
@end
