//
//  HomeViewController.h
//  FeedMeNow
//
//  Created by Jamey Roland on 7/7/14.
//  Copyright (c) 2014 Jamey Roland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <FlatUIKit.h>
#import <FBGlowLabel.h>

#import <Pop/Pop.h>

@interface HomeViewController : UIViewController <CLLocationManagerDelegate>

-(void) updateUserInterface;

@property (strong, nonatomic) IBOutlet UILabel *suggestionLabel;
@property (strong, nonatomic) IBOutlet FBGlowLabel *entreeLabel;
@property (strong, nonatomic) IBOutlet FBGlowLabel *fromLabel;
@property (strong, nonatomic) IBOutlet FBGlowLabel *restaurantLabel;
@property (strong, nonatomic) IBOutlet FUIButton *feedMeNowButton;
@property (strong, nonatomic) IBOutlet FUIButton *generateFoodButton;


@end
