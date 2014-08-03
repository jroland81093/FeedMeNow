//
//  HomeViewController.m
//  FeedMeNow
//
//  Created by Jamey Roland on 7/7/14.
//  Copyright (c) 2014 Jamey Roland. All rights reserved.
//

#import "HomeViewController.h"
#import "Suggestion.h"

@interface HomeViewController ()
{
    NSMutableString *currentPhoneNumber;
    NSMutableDictionary *allSuggestions;
    NSMutableArray *allRestaurantNames;
}

@end

@implementation HomeViewController

- (id) initWithSuggestions:(NSMutableArray *)suggestions withLoadingViewController: (LoadingViewController *)parent
{
    self = [super init];
    if (self) {
        allSuggestions = [[NSMutableDictionary alloc] init];
        
        for (Suggestion *suggestion in suggestions)
        {
            NSString *restaurantName = [suggestion restaurantName];
            
            
        }
        parent = nil;
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

    NSUInteger randomRestaurantIndex = rand() % [allRestaurantNames count];
    NSString *restaurant = [allRestaurantNames objectAtIndex:randomRestaurantIndex];
    NSLog(@"%@", [allSuggestions valueForKey:restaurant]);
    /*
    Suggestion *suggestion = [allSuggestions objectAtIndex:randomIndex];
    [[self entreeLabel] setText:[suggestion entreeName]];
    [[self restaurantLabel] setText:[suggestion restaurantName]];
    currentPhoneNumber = [[suggestion phoneNumber] mutableCopy];
     */

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
@end
