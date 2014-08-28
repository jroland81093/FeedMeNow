//
//  SuggestionViewController.h
//  FeedMeNow
//
//  Created by James Roland on 8/27/14.
//  Copyright (c) 2014 Jamey Roland. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SuggestionViewController : UIViewController

- (id) initWithSuggestions:(NSMutableDictionary *)suggestions withRestaurantIdentifiers: (NSMutableArray *)restaurantIdentifiers;

@property (strong, nonatomic) IBOutlet UILabel *suggestionLabel;
@property (weak, nonatomic) IBOutlet UILabel *atLabel;

@property (weak, nonatomic) IBOutlet UILabel *entreeLabel;
@property (weak, nonatomic) IBOutlet UILabel *restaurantLabel;

@end
