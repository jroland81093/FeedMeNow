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
    NSMutableString *currentPhoneNumber;
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
        
        currentPhoneNumber = [[NSMutableString alloc] init];
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
    //FeedMeNow Button
    [self feedMeNowButton].buttonColor = [UIColor turquoiseColor];
    [self feedMeNowButton].shadowColor = [UIColor greenSeaColor];
    [self feedMeNowButton].shadowHeight = 3.0f;
    [self feedMeNowButton].cornerRadius = 6.0f;
    [self feedMeNowButton].titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [[self feedMeNowButton] setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    
    //Generate Food Button
    [self generateFoodButton].buttonColor = [UIColor alizarinColor];
    [self generateFoodButton].shadowColor = [UIColor pomegranateColor];
    [self generateFoodButton].shadowHeight = 3.0f;
    [self generateFoodButton].cornerRadius = 6.0f;
    [self generateFoodButton].titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [[self generateFoodButton] setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    
    //Labels
    [[self suggestionLabel] setTextColor:[UIColor whiteColor]];
    [[self entreeLabel] setTextColor:[UIColor whiteColor]];
    [[self fromLabel] setTextColor:[UIColor whiteColor]];
    [[self restaurantLabel] setTextColor:[UIColor whiteColor]];
    
    //Set glow aspect on labels
    [[self entreeLabel] setGlowColor:[UIColor blackColor]];
    [[self entreeLabel] setGlowSize:10];
    [[self restaurantLabel] setGlowColor:[UIColor blackColor]];
    [[self restaurantLabel] setGlowSize:10];
    
}
- (void)updateUserInterface
{
    //Unhide all buttons
    [self presentRandomFoodSuggestion:nil];
    [[self feedMeNowButton] setHidden:NO];
    [[self feedMeNowButton] setEnabled:YES];
    [[self generateFoodButton] setHidden:NO];
    [[self generateFoodButton] setEnabled:YES];
    
    //Unhide all labels
    [[self suggestionLabel] setHidden:NO];
    [[self entreeLabel] setHidden:NO];
    [[self fromLabel] setHidden:NO];
    [[self restaurantLabel] setHidden:NO];

    POPDecayAnimation *animation = [POPDecayAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    [animation setVelocity:@(800.)];
    [[[self MACircleIndicatorView] layer] pop_addAnimation:animation forKey:@"slide"];
    [[[self loadingLabel] layer] pop_addAnimation:animation forKey:@"slide"];
}



- (IBAction)refresh:(id)sender {
    [locationManager startUpdatingLocation];
}
#pragma mark - UDF
- (IBAction)presentRandomFoodSuggestion:(id)sender {
    if ([[[self ordrClient] deliverableRestaurants] count] > 0 &&
        [[self ordrClient] numCompletedRequests] == [[[self ordrClient] deliverableRestaurants] count])
    {
        NSUInteger randomRestaurantIndex = rand()%[[[self ordrClient] deliverableRestaurantsIDs] count];
        NSString *randomRestaurantKey = [[[self ordrClient] deliverableRestaurantsIDs] objectAtIndex:randomRestaurantIndex];
        Restaurant *randomRestaurant = [[[self ordrClient] deliverableRestaurants] valueForKey:randomRestaurantKey];
        //Find random restaurant
        /*
        NSUInteger randomEntreeIndex = rand()%[[randomRestaurant orderableEntrees] count];
        NSString *randomEntree = [[randomRestaurant orderableEntrees] objectAtIndex:randomEntreeIndex];
        currentPhoneNumber = [[randomRestaurant phoneNumber] mutableCopy];
        
        [[self restaurantLabel] setText:[randomRestaurant name]];
        [[self entreeLabel] setText:randomEntree];
         */
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"You must allow location services to find nearby food." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alertView show];
    }
}

- (IBAction)feedMeNow:(id)sender {
    NSString *phoneDigits = [[currentPhoneNumber componentsSeparatedByCharactersInSet:
                            [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                           componentsJoinedByString:@""];
    NSString *phonePrompt = [NSString stringWithFormat:@"telprompt://%@", phoneDigits];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phonePrompt]];
    NSLog(@"User called %@", currentPhoneNumber);
}

@end
