//
//  HomeViewController.m
//  FeedMeNow
//
//  Created by Jamey Roland on 7/7/14.
//  Copyright (c) 2014 Jamey Roland. All rights reserved.
//

#import "HomeViewController.h"
#import "YelpClient.h"
#import "OrdrClient.h"
#import "Restaurant.h"

#define ACTIVITY_PROGRESS_DEFAULT .5


@interface HomeViewController ()
{
    CLLocationManager *locationManager;
    CLLocationCoordinate2D userLocation;
}

@property (nonatomic, strong) YelpClient *yelpClient;
@property (nonatomic, strong) OrdrClient *ordrClient;

@end

@implementation HomeViewController

@synthesize yelpClient;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setOrdrClient:[[OrdrClient alloc] initWithViewController:self]];
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDelegate:self];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSUserDefaults Load.
    //If not, then update location.
    [self generateUserInterface];
    [locationManager startUpdatingLocation];
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User Interface

- (void)generateUserInterface
{
    [[self MACircleIndicatorView] value];
    [[self generateFoodButton] setButtonColor:[UIColor turquoiseColor]];
}
- (void)updateUserInterface
{
    
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [manager stopUpdatingLocation];
    if (userLocation.latitude == 0 && userLocation.longitude == 0)
    {
        CLLocation *location = [locations objectAtIndex:0];
        userLocation = [location coordinate];
        if ([[self ordrClient] findRestaurantsNearCoordinate:userLocation])
        {
            [[self MACircleIndicatorView] setValue:ACTIVITY_PROGRESS_DEFAULT];
            [[self ordrClient] generateAllEntrees];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Could not find user address, try refreshing." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
            [alertView show];
        }
        
    }
}

#pragma mark - UDF
- (IBAction)presentRandomFoodSuggestion:(id)sender {
    if ([[[self ordrClient] deliverableRestaurants] count] > 0 &&
        [[self ordrClient] numCompletedRequests] == [[[self ordrClient] deliverableRestaurants] count])
    {
        NSUInteger randomRestaurantIndex = rand()%[[[self ordrClient] deliverableRestaurants] count];
        Restaurant *randomRestaurant = [[[self ordrClient] deliverableRestaurants] objectAtIndex:randomRestaurantIndex];
        NSUInteger randomEntreeIndex = rand()%[[randomRestaurant orderableEntrees] count];
        NSString *randomEntree = [[randomRestaurant orderableEntrees] objectAtIndex:randomEntreeIndex];
        
        [[self restaurantLabel] setText:[randomRestaurant name]];
        [[self entreeLabel] setText:randomEntree];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"You must allow location services to find nearby food" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alertView show];
    }
}

#pragma mark - Location Error Handling
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"You must enable Location Services" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    [alertView show];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status != kCLAuthorizationStatusAuthorized)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"You must enable Location Services" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alertView show];
    }
}
@end
