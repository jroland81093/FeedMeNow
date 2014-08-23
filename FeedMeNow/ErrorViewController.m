//
//  ErrorViewController.m
//  FeedMeNow
//
//  Created by James Roland on 8/23/14.
//  Copyright (c) 2014 Jamey Roland. All rights reserved.
//

#import "ErrorViewController.h"
#import "LoadingViewController.h"

@interface ErrorViewController ()

@end

@implementation ErrorViewController

- (id)initWithError: (NSString *)error
{
    self = [super init];
    if (self)
    {
        [[self errorLabel] setText:error];
    }
    return self;
}

- (IBAction)tryAgain:(id)sender {
    LoadingViewController *lvc = [[LoadingViewController alloc] init];
    [self presentViewController:lvc animated:YES completion:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
