//
//  WifiAuth.m
//  Pods-WifiAuth_Example
//
//  Created by Felix Krause on 12/17/18.
//

#import "WifiAuth.h"
#import <SystemConfiguration/SystemConfiguration.h>

@interface WifiAuth()

@property (nonatomic, assign) Boolean currentlyShownPopup;
@property (nonatomic, assign) Boolean offeredToShowPopup;

@end

@implementation WifiAuth

+ (instancetype)sharedWifiAuth {
    static dispatch_once_t once;
    static WifiAuth *sharedWifiAuth;
    dispatch_once(&once, ^ { sharedWifiAuth = [[self alloc] init]; });
    return sharedWifiAuth;
}

- (void)startMonitoring {
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(checkForNetworkConnection)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)checkForNetworkConnection {
    if (![self isInterventionRequired]) {
        return;
    }
    if (self.currentlyShownPopup) {
        return;
    }
    if (self.offeredToShowPopup) {
        return;
    }
    
    // TODO: replace all those variables with other ones
    self.currentlyShownPopup = YES;
    self.offeredToShowPopup = YES;
    
    // Login here
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"WiFi Authentication needed"
                                                                   message:@"Looks like the WiFi you're connected with, requires some sort of login. Open the login page now?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    __weak __typeof(self) weakSelf = self;
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {
                                                              weakSelf.currentlyShownPopup = NO;
                                                              
                                                              // TODO: replace with in-app browser
                                                              // In-app browser allows us to detect once the WiFi connection is established
                                                              // And show the `Done` button
                                                              NSURL *urlToOpen = [NSURL URLWithString:@"http://captive.apple.com/hotspot-detect.html"];
                                                              [[UIApplication sharedApplication] openURL:urlToOpen];
                                                          }];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              weakSelf.currentlyShownPopup = NO;
                                                          }];
    
    [alert addAction:yesAction];
    [alert addAction:noAction];
    
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];

}


// Taken from https://github.com/tonymillion/Reachability
// BSD licensed
- (BOOL)isInterventionRequired
{
    SCNetworkReachabilityFlags flags;
    id hostAddress = @"apple.com";
    SCNetworkReachabilityRef reachabilityRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)hostAddress);
    
    if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags))
    {
        return ((flags & kSCNetworkReachabilityFlagsConnectionRequired) &&
                (flags & kSCNetworkReachabilityFlagsInterventionRequired));
    }
    
    return NO;
}

@end
