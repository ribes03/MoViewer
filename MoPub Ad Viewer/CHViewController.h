//
//  CHViewController.h
//  MoPub Ad Viewer
//
//  Created by Christian Hresko on 4/15/13.
//  Copyright (c) 2013 Christian Hresko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPAdView.h"
#import "MPInterstitialAdController.h"

@interface CHViewController : UIViewController<MPAdViewDelegate, MPInterstitialAdControllerDelegate, UITextFieldDelegate> {
    MPAdView* adView;
    MPInterstitialAdController* interstitial;
}

@property (weak, nonatomic) IBOutlet UITextField *bannerIDField;
@property (weak, nonatomic) IBOutlet UITextField *interstitialIDField;
@property (weak, nonatomic) IBOutlet UILabel *interstitialText;

@end
