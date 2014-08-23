//
//  LoadingViewController.m
//  FeedMeNow
//
//  Created by Jamey Roland on 7/29/14.
//  Copyright (c) 2014 Jamey Roland. All rights reserved.
//

#import "LoadingViewController.h"
#import "OrdrClient.h"
#import "HomeViewController.h"

#define LABEL_FONT_SIZE (int) 26

@interface LoadingViewController ()
{
    OrdrClient *client;
    CLLocationManager *locationManager;
    CLLocationCoordinate2D userLocation;
    
    NSMutableDictionary *allSuggestions;
    //Storage for restaurant suggestions.
}

@end

@implementation LoadingViewController

- (id)initWithParentViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self) {
        viewController = nil;
        
        client = [[OrdrClient alloc] initWithLoadingViewController:self];
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDelegate:self];
        allSuggestions = [[NSMutableDictionary alloc] init];
        
        userLocation.latitude = 0;
        userLocation.longitude = 0;
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        client = [[OrdrClient alloc] initWithLoadingViewController:self];
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDelegate:self];
        allSuggestions = [[NSMutableDictionary alloc] init];
        
        userLocation.latitude = 0;
        userLocation.longitude = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIFont *labelFont = [UIFont fontWithName:@"Bellota-Bold" size:LABEL_FONT_SIZE];
    
    [[self progressIndicator] setColor:[UIColor belizeHoleColor]];
    [[self progressLabel] setText:@"Finding your location..."];
    [[self progressLabel] setFont:labelFont];
    [locationManager startUpdatingLocation];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    client = nil;
    NSLog(@"Memory warning");
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI

- (void)generateUserInterface
{
    HomeViewController *hvc = [[HomeViewController alloc] initWithSuggestions:allSuggestions withRestaurantIdentifiers:[self suggestionRestaurantIDs]];
    [self presentViewController:hvc animated:YES completion:nil];
}

- (IBAction)refresh:(id)sender {
    [locationManager startUpdatingLocation];
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
            [[self progressIndicator] setColor:[UIColor emerlandColor]];
            [[self progressLabel] setText:@"Generating menu information..."];
            [client generateAllEntreesToDictionary:allSuggestions];
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

#pragma mark - Helper

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
