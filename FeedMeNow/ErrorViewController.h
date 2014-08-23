//
//  ErrorViewController.h
//  FeedMeNow
//
//  Created by James Roland on 8/23/14.
//  Copyright (c) 2014 Jamey Roland. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ErrorViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

-(id)initWithError: (NSString *)error;
@end
