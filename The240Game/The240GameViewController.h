//
//  The240GameViewController.h
//  The240Game
//
//  Created by Yuval on 8/12/14.
//  Copyright (c) 2014 Udi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@class GADBannerView;

@interface The240GameViewController : UIViewController <ADBannerViewDelegate>
{
    ADBannerView *bannerView;
}

@property (retain, nonatomic) IBOutlet ADBannerView *bannerView;

@property (weak, nonatomic) IBOutlet GADBannerView *gadBannerView;

@end
