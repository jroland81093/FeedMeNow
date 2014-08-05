//
//  HomeViewController.h
//  FeedMeNow
//
//  Created by Jamey Roland on 7/7/14.
//  Copyright (c) 2014 Jamey Roland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FlatUIKit.h>
#import <FBGlowLabel.h>
#import <Pop/Pop.h>
#import "LoadingViewController.h"

@interface HomeViewController : UIViewController

- (id) initWithSuggestions:(NSMutableDictionary *)suggestions withRestaurantIdentifiers: (NSMutableArray *)restaurantIdentifiers;

//Static text
@property (strong, nonatomic) IBOutlet UILabel *suggestionLabel;
@property (weak, nonatomic) IBOutlet UILabel *atLabel;

@property (weak, nonatomic) IBOutlet UILabel *entreeLabel;
@property (weak, nonatomic) IBOutlet UILabel *restaurantLabel;



@end
