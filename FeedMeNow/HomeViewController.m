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
#define Y_BLUE_COMPONENT (int) 177/255

//Coral color
#define C_RED_COMPONENT (float) 238/255
#define C_GREEN_COMPONENT (float) 131/255
#define C_BLUE_COMPONENT (int) 94/255

#define LABEL_FONT_SIZE (int) 26
#define SUGGESTION_FONT_SIZE (int) 20

@interface HomeViewController ()
{
    NSMutableString *currentPhoneNumber;
    NSMutableArray *allSuggestions;
    NSMutableDictionary *allSuggestionsDictionary;
    
    //UI
    __weak IBOutlet UIView *logoBackground;
}

@end

@implementation HomeViewController

- (id) initWithSuggestions:(NSMutableArray *)suggestions
{
    self = [super init];
    if (self) {
    
        allSuggestionsDictionary = [[NSMutableDictionary alloc] init];
        allSuggestions = suggestions;
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
    
    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);
        
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }
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

    NSUInteger randomIndex = rand() % [allSuggestions count];
    Suggestion *suggestion = [allSuggestions objectAtIndex:randomIndex];
    [[self entreeLabel] setText:[suggestion entreeName]];
    [[self restaurantLabel] setText:[suggestion restaurantName]];
    currentPhoneNumber = [[suggestion phoneNumber] mutableCopy];
}

@end
