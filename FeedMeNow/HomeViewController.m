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
        [self generateUserInterface];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self generateButton:[self feedMeNowButton] WithColor:[UIColor turquoiseColor] shadowColor:[UIColor greenSeaColor] titleColor:[UIColor cloudsColor]];
    [self generateButton:[self generateFoodButton] WithColor:[UIColor alizarinColor] shadowColor:[UIColor pomegranateColor] titleColor:[UIColor cloudsColor]];
    [self generateGlowLabel:[self entreeLabel]];
    [self generateGlowLabel:[self restaurantLabel]];
    //[self generateRandomSuggestion:nil];
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


#pragma mark - Helper Functions
- (void) generateButton: (FUIButton *)button
              WithColor: (UIColor *)color
            shadowColor: (UIColor *)shadowColor
             titleColor: (UIColor *)titleColor
{
    [button setButtonColor:color];
    [button setShadowColor:shadowColor];
    [button setShadowHeight:3.0f];
    [button setCornerRadius:6.0f];
    [[button titleLabel] setFont:[UIFont boldFlatFontOfSize:16]];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button setEnabled:YES];
}

- (void) generateGlowLabel: (FBGlowLabel *)label
{
    [label setGlowColor:[UIColor blackColor]];
    [label setGlowSize:10];
}

- (void) generateUserInterface
{
    UIColor *mustardColor = [[UIColor alloc] initWithRed:Y_RED_COMPONENT green:Y_GREEN_COMPONENT blue:Y_BLUE_COMPONENT alpha:1];
    [[self view] setBackgroundColor:mustardColor];
    
    UIColor *coralColor = [[UIColor alloc] initWithRed:C_RED_COMPONENT green:C_GREEN_COMPONENT blue:C_BLUE_COMPONENT alpha:1];
    [logoBackground setBackgroundColor:coralColor];
}
@end
