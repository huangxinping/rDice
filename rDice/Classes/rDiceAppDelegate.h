//
//  rDiceAppDelegate.h
//  rDice
//
//  Created by o0402 on 11-7-11.
//  Copyright inblue 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenFeint.h"
#import "SampleOFDelegate.h"
#import <GameKit/GameKit.h>

@class RootViewController;

@interface rDiceAppDelegate : NSObject <UIApplicationDelegate> 
{
	UIWindow			*window;
	RootViewController	*viewController;
	SampleOFDelegate	*ofDelegate;
}

@property (nonatomic, retain) UIWindow *window;

- (void)initOpenfeint;

@end
