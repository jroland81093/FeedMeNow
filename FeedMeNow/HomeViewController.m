//
//  HomeViewController.m
//  FeedMeNow
//
//  Created by Jamey Roland on 7/7/14.
//  Copyright (c) 2014 Jamey Roland. All rights reserved.
//

#import "HomeViewController.h"
#import "Suggestion.h"

//Yellow color
#define Y_RED_COMPONENT (float) 246/255
#define Y_GREEN_COMPONENT (float) 222/255
#define Y_BLUE_COMPONENT (float) 177/255

//Coral color
#define C_RED_COMPONENT (float) 238/255
#define C_GREEN_COMPONENT (float) 131/255
#define C_BLUE_COMPONENT (float) 94/255

#define LABEL_FONT_SIZE (int) 26

@interface HomeViewController ()
{
    NSMutableString *currentPhoneNumber;
    NSMutableArray *restaurantIDs;
    NSMutableDictionary *allSuggestions;
    
    //UI
    __weak IBOutlet UIView *logoBackground;
}

@end

@implementation HomeViewController

- (id) initWithSuggestions:(NSMutableDictionary *)suggestions withRestaurantIdentifiers: (NSMutableArray *)restaurantIdentifiers;
{
    self = [super init];
    if (self) {
        allSuggestions = suggestions;
        restaurantIDs = restaurantIdentifiers;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Set top primary background color
    UIColor *mustardColor = [[UIColor alloc] initWithRed:Y_RED_COMPONENT green:Y_GREEN_COMPONENT blue:Y_BLUE_COMPONENT alpha:1];
    [[self view] setBackgroundColor:mustardColor];
    
    //Set top logo color
    UIColor *coralColor = [[UIColor alloc] initWithRed:C_RED_COMPONENT green:C_GREEN_COMPONENT blue:C_BLUE_COMPONENT alpha:1];
    [logoBackground setBackgroundColor:coralColor];
    
    //Set fixed buttons
    UIFont *labelFont = [UIFont fontWithName:@"Bellota-Italic" size:LABEL_FONT_SIZE];
    [[self suggestionLabel] setFont:labelFont];
    [[self atLabel] setFont:labelFont];
    
    //Set dynamic buttons
    UIFont *dynamicFont = [UIFont fontWithName:@"Cabin-Bold" size:LABEL_FONT_SIZE];
    [[self entreeLabel] setFont:dynamicFont];
    [[self restaurantLabel] setFont:dynamicFont];
    
    //Filter through suggestions array, then generate a random suggestion.
    [self filterSuggestions];
    [self generateRandomSuggestion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UDF

- (IBAction)feedMeNow:(id)sender {

    NSString *phoneDigits = [[currentPhoneNumber componentsSeparatedByCharactersInSet:
                            [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                           componentsJoinedByString:@""];
    NSString *phonePrompt = [NSString stringWithFormat:@"telprompt://%@", phoneDigits];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phonePrompt]];
    NSLog(@"User called %@", currentPhoneNumber);

}

- (IBAction)generateRandomSuggestion:(id)sender {
    NSUInteger randomRestaurantIndex = rand() % [restaurantIDs count];
    NSString *randomRestaurantName = [restaurantIDs objectAtIndex:[self randomIndex:randomRestaurantIndex withCountCap:[restaurantIDs count]]];
    NSMutableArray *entrees = [allSuggestions valueForKey:randomRestaurantName];
    //For each restaurant ID
    NSUInteger randomEntreeIndex = rand() % [entrees count];
    Suggestion *suggestion = [entrees objectAtIndex:[self randomIndex:randomEntreeIndex withCountCap:[entrees count]]];
    [[self entreeLabel] setText:[suggestion entreeName]];
    [[self restaurantLabel] setText:[suggestion restaurantName]];
    currentPhoneNumber = [[suggestion phoneNumber] mutableCopy];
}

#pragma mark - Helper
- (void)filterSuggestions
{
    for (NSString *restaurantID in [restaurantIDs copy])
    {
        NSMutableArray *restaurants = [allSuggestions valueForKey:restaurantID];
        if (![restaurants count])
        {
            [restaurantIDs removeObjectIdenticalTo:restaurantID];
        }
    }
    NSLog(@"%lu restaurants total", (unsigned long)[restaurantIDs count]);
}

- (NSUInteger) randomIndex:(NSUInteger)randomParameter withCountCap:(NSUInteger)cap;
{
    NSUInteger randomInteger = rand() % 7; //Behavior of prime numbers mocks more random behavior.
    NSUInteger randomTime = (NSUInteger)[[NSDate date] timeIntervalSince1970] % cap;
    return (randomInteger + randomTime * randomParameter) % cap;
}

@end
