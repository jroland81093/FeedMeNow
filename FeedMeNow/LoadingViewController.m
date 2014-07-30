//
//  LoadingViewController.m
//  FeedMeNow
//
//  Created by Jamey Roland on 7/29/14.
//  Copyright (c) 2014 Jamey Roland. All rights reserved.
//

#import "LoadingViewController.h"
#import "OrdrClient.h"


@interface LoadingViewController ()
{
    OrdrClient *client;
    CLLocationManager *locationManager;
    CLLocationCoordinate2D userLocation;
}

@end

@implementation LoadingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        client = [[OrdrClient alloc] initWithLoadingViewController:self];
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDelegate:self];
        userLocation.latitude = 0;
        userLocation.longitude = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [locationManager startUpdatingLocation];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UDF

- (void)generateUserInterface
{
    return;
}


#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [manager stopUpdatingLocation];
    if (userLocation.latitude == 0 && userLocation.longitude == 0)
    {
        CLLocation *location = [locations objectAtIndex:0];
        userLocation = [location coordinate];
        if ([client findRestaurantsNearCoordinate:userLocation])
        {
            [client generateAllEntrees];
        }
        else
        {
            [self presentAddressAPIError];
        }
    }
}

#pragma mark - Location Error Handling
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self presentLocationError];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status != kCLAuthorizationStatusAuthorized)
    {
        [self presentLocationError];
    }
}

#pragma mark - Error Handling Functions

- (void) presentLocationError
//User didn't allow for location services
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"You must enable Location Services" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    [alertView show];
}

- (void) presentAddressAPIError
//API came across an error.
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Could not find user address, try refreshing." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    [alertView show];
}



@end
