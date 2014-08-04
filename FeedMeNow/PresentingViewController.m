//
//  PresentingViewController.m
//  FeedMeNow
//
//  Created by James Roland on 8/3/14.
//  Copyright (c) 2014 Jamey Roland. All rights reserved.
//

#import "PresentingViewController.h"
#import "LoadingViewController.h"
#import "HomeViewController.h"

#define RED_COMPONENT (float) 238/255
#define GREEN_COMPONENT (float) 131/255
#define BLUE_COMPONENT (int) 94/255

@interface PresentingViewController ()

@end

@implementation PresentingViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        UIColor *coralColor = [[UIColor alloc] initWithRed:RED_COMPONENT green:GREEN_COMPONENT blue:BLUE_COMPONENT alpha:1];
        [[self view] setBackgroundColor:coralColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [self performSelector:@selector(presentNextViewController) withObject:nil afterDelay:1.5];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)presentNextViewController
{
    
    LoadingViewController *lvc = [[LoadingViewController alloc] init];
    [self presentViewController:lvc animated:YES completion:nil];
}
@end
