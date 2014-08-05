//
//  LoadingViewController.h
//  FeedMeNow
//
//  Created by Jamey Roland on 7/29/14.
//  Copyright (c) 2014 Jamey Roland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <FBGlowLabel.h>
#import <RZSquaresLoading.h>


@interface LoadingViewController : UIViewController <CLLocationManagerDelegate>

- (void)generateUserInterface;
//Used as a callback function after API responses.

@property (strong, nonatomic) IBOutlet RZSquaresLoading *progressIndicator;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (strong, nonatomic) NSMutableArray *restaurantIDs;

@end
