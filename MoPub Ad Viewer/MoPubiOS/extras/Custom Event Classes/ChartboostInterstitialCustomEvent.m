//
//  ChartboostInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "ChartboostInterstitialCustomEvent.h"
#import "MPInstanceProvider.h"
#import "MPLogging.h"

#define kChartboostAppID        @"YOUR_CHARTBOOST_APP_ID"
#define kChartboostAppSignature @"YOUR_CHARTBOOST_APP_SIGNATURE"

@interface MPInstanceProvider (ChartboostInterstitials)

- (Chartboost *)buildChartboost;

@end

@implementation MPInstanceProvider (ChartboostInterstitials)

- (Chartboost *)buildChartboost
{
    return [Chartboost sharedChartboost];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface ChartboostInterstitialCustomEvent ()

@property (nonatomic, retain) Chartboost *chartboost;

@end

@implementation ChartboostInterstitialCustomEvent

@synthesize chartboost = _chartboost;

#pragma mark - MPInterstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    MPLogInfo(@"Requesting Chartboost interstitial.");

	NSString *appId = kChartboostAppID;
	NSString *appSignature = kChartboostAppSignature;

    if ([appId length] > 0 && [appSignature length] > 0) {
        self.chartboost = [[MPInstanceProvider sharedProvider] buildChartboost];
        self.chartboost.appId = appId;
		self.chartboost.appSignature = appSignature;
        self.chartboost.delegate = self;

        [self.chartboost startSession];
        [self.chartboost cacheInterstitial];
    } else {
        MPLogInfo(@"Failed to load Chartboost interstitial: missing either appId or appSignature.");
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
    }
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    if ([self.chartboost hasCachedInterstitial]) {
        MPLogInfo(@"Chartboost interstitial will be shown.");

        // Normally, we call the "will appear" and "did appear" methods in response to
        // callbacks from Third Party Integrations. Unfortunately, Chartboost doesn't seem to have
        // such callbacks, so we call the methods manually.
        [self.delegate interstitialCustomEventWillAppear:self];
        [self.chartboost showInterstitial];
        [self.delegate interstitialCustomEventDidAppear:self];
    } else {
        MPLogInfo(@"Failed to show Chartboost interstitial.");
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
    }
}

- (void)dealloc
{
    // Don't set the delegate to nil unless we are the delegate, because another instance of
    // this custom class could be active (which would make it the active delegate instead). Note:
    // this check is only necessary because the Chartboost object is a shared instance.
    if (self.chartboost.delegate == self) {
        self.chartboost.delegate = nil;
    }

    self.chartboost = nil;

    [super dealloc];
}

#pragma mark - ChartboostDelegate

- (void)didCacheInterstitial:(NSString *)location
{
    MPLogInfo(@"Successfully loaded Chartboost interstitial.");

    [self.delegate interstitialCustomEvent:self didLoadAd:self.chartboost];
}

- (void)didFailToLoadInterstitial:(NSString *)location
{
    MPLogInfo(@"Failed to load Chartboost interstitial.");

    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)didDismissInterstitial:(NSString *)location
{
    MPLogInfo(@"Chartboost interstitial was dismissed.");

    // Chartboost doesn't seem to have a separate callback for the "will disappear" event, so we
    // signal "will disappear" manually.

    [self.delegate interstitialCustomEventWillDisappear:self];
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)didClickInterstitial:(NSString *)location
{
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

@end
