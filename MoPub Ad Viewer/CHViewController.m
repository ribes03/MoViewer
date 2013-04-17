//
//  CHViewController.m
//  MoPub Ad Viewer
//
//  Created by Christian Hresko on 4/15/13.
//  Copyright (c) 2013 Christian Hresko. All rights reserved.
//

#import "CHViewController.h"

@interface CHViewController ()
- (void)loadInterstitialWithID:(NSString*)ID;
- (void)loadBannerWithID:(NSString*)ID;
@end

@implementation CHViewController

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.bannerIDField]) {
        [self loadBannerWithID:self.bannerIDField.text];
        [self.bannerIDField resignFirstResponder];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSString* path = [libraryPath stringByAppendingPathComponent:@"banner"];
            NSError* error;
            [self.bannerIDField.text writeToFile:path atomically:YES encoding:NSASCIIStringEncoding error:&error];
        });
    }
    
    if ([textField isEqual:self.interstitialIDField]) {
        [self loadInterstitialWithID:self.interstitialIDField.text];
        [self.interstitialIDField resignFirstResponder];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSString* path = [libraryPath stringByAppendingPathComponent:@"interstitial"];
            NSError* error;
            [self.interstitialIDField.text writeToFile:path atomically:YES encoding:NSASCIIStringEncoding error:&error];
        });
    }
    
    return YES;
}

- (void)loadView {
    [super loadView];
    
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* path = [libraryPath stringByAppendingPathComponent:@"banner"];
    NSError* error;
    self.bannerIDField.text = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&error];
    if ([self.bannerIDField.text length]) {
        [self loadBannerWithID:self.bannerIDField.text];
    }
    
    path = [libraryPath stringByAppendingPathComponent:@"interstitial"];
    self.interstitialIDField.text = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&error];
    if ([self.interstitialIDField.text length]) {
        [self loadInterstitialWithID:self.interstitialIDField.text];
    }
}

- (void)loadBannerWithID:(NSString*)ID {
    adView = [[MPAdView alloc] initWithAdUnitId:ID
                                           size:MOPUB_BANNER_SIZE];
    
    // Register your view controller as the MPAdView's delegate.
    adView.delegate = self;
    
    // Set the ad view's frame (in our case, to occupy the bottom of the screen).
    CGRect frame = adView.frame;
    CGSize size = [adView adContentViewSize];
    frame.origin.y = [[UIScreen mainScreen] applicationFrame].size.height - size.height;
    adView.frame = frame;
    [adView setBackgroundColor:[UIColor blackColor]];
    
    // Add the ad view to your controller's view hierarchy.
    [adView removeFromSuperview];
    [self.view addSubview:adView];
    [adView loadAd];
}

- (void)loadInterstitialWithID:(NSString*)ID {
    // Instantiate the interstitial using the class convenience method.
    interstitial = [MPInterstitialAdController
                     interstitialAdControllerForAdUnitId:ID];
    interstitial.delegate = self;
    // Fetch the interstitial ad.
    [interstitial loadAd];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bannerIDField.delegate = self;
    self.interstitialIDField.delegate = self;
    [self.interstitialText setTextColor:[UIColor whiteColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial {
    [self.interstitialText setTextColor:[UIColor blackColor]];
}

// Optional delegate callback that is fired after the interstitial is dismissed.
- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitialIn {
    // Destroy the interstitial, since it is only intended to be used once.
    [MPInterstitialAdController removeSharedInterstitialAdController:interstitialIn];
    
    // Nil out any references to the interstitial object, since they are no longer
    // valid after the previous call (unless you have manually retained the object).
    //interstitial = nil;
    
    [self.interstitialText setTextColor:[UIColor whiteColor]];
    [self loadInterstitialWithID:self.interstitialIDField.text];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (interstitial.ready)
        [interstitial showFromViewController:self];
    else {
        // Present a scoreboard or continue as usual.
    }
}


@end
