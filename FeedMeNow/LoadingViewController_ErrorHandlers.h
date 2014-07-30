//
//  LoadingViewController_ErrorHandlers.h
//  FeedMeNow
//
//  Created by Jamey Roland on 7/29/14.
//  Copyright (c) 2014 Jamey Roland. All rights reserved.
//

#import "LoadingViewController.h"

@interface LoadingViewController ()

- (void) presentLocationError
//User didn't allow for location services
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"You must enable Location Services" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    [alertView show];
}

- (void) presentAddressAPIError
//
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Could not find user address, try refreshing." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    [alertView show];
}

@end
