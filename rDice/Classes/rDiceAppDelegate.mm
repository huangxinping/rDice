//
//  rDiceAppDelegate.m
//  rDice
//
//  Created by o0402 on 11-7-11.
//  Copyright inblue 2011. All rights reserved.
//

#import "cocos2d.h"

#import "rDiceAppDelegate.h"
#import "GameConfig.h"
#import "GameLayerScene.h"
#import "RootViewController.h"
#import "SimpleAudioEngine.h"

@implementation rDiceAppDelegate

@synthesize window;

- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController

//	CC_ENABLE_DEFAULT_GL_STATES();
//	CCDirector *director = [CCDirector sharedDirector];
//	CGSize size = [director winSize];
//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
//	sprite.position = ccp(size.width/2, size.height/2);
//	sprite.rotation = -90;
//	[sprite visit];
//	[[director openGLView] swapBuffers];
//	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}
- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	CCDirector *director = [CCDirector sharedDirector];
	
	// Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
						];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
//	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
//	if( ! [director enableRetinaDisplay:YES] )
//		CCLOG(@"Retina Display Not supported");
	
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
	// IMPORTANT:
	// By default, this template only supports Landscape orientations.
	// Edit the RootViewController.m file to edit the supported orientations.
	//
//#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
//#else
//	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
//#endif
	
	[director setAnimationInterval:1.0/60];
	[director setDisplayFPS:NO];
	
	
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];
	
	// make the View Controller a child of the main window
	[window addSubview: viewController.view];
	
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	
	// Removes the startup flicker
	[self removeStartupFlicker];
	
	// login openfeint
	[self initOpenfeint];
	
	// once init local data
	BOOL bOnceInit = [[NSUserDefaults standardUserDefaults] boolForKey:@"OnceInit"];
	if (!bOnceInit) 
	{
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"OnceInit"];
		[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"EasyLevel"];
		[[NSUserDefaults standardUserDefaults] setInteger:11 forKey:@"MediumLevel"];
		[[NSUserDefaults standardUserDefaults] setInteger:26 forKey:@"HardLevel"];
		
		[OpenFeint launchDashboard];
	}
	
	// play backgournd music and preload sound
	[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bkmusic.mp3" loop:YES];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"buttonsound.mp3"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"movesound.mp3"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"winsound.mp3"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"zonesound.mp3"];
	
	// Run the intro Scene
	[[CCDirector sharedDirector] runWithScene: [GameLayerScene scene]];		
}

- (void)initOpenfeint
{
	NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInt:UIInterfaceOrientationPortrait], 
							  OpenFeintSettingDashboardOrientation, 
							  [NSNumber numberWithBool:YES], 
							  OpenFeintSettingDisableUserGeneratedContent, nil];
	
	ofDelegate = [SampleOFDelegate new];
	OFDelegatesContainer* delegates = [OFDelegatesContainer containerWithOpenFeintDelegate:ofDelegate];
	[OpenFeint initializeWithProductKey:@"vLMuDIWLXnlGmpn6IpjO8w"
							  andSecret:@"cBbwTe1qNG8Fw2FNi33W9wqfmlJ0vr11ez0qv3GGQU"
						 andDisplayName:@"rDice"
							andSettings:settings    // see OpenFeintSettings.h
						   andDelegates:delegates]; // see OFDelegatesContainer.h
	
}

- (void)applicationWillResignActive:(UIApplication *)application 
{
	[OpenFeint applicationWillResignActive];
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application 
{
	[OpenFeint applicationDidBecomeActive];
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application 
{
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application 
{
	[OpenFeint applicationWillEnterForeground];
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application 
{
	[OpenFeint applicationWillEnterForeground];
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application 
{
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	
	[window release];
	
	[OpenFeint shutdown];
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application 
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc 
{
	[ofDelegate release];
	[[CCDirector sharedDirector] release];
	[window release];
	[super dealloc];
}

@end
