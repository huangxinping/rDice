//
//  GameLoadDelegate.m
//  loadingScene
//
//  Created by o0402 on 11-7-8.
//  Copyright 2011 inblue. All rights reserved.
//

#import "GameLoadDelegate.h"

#define LOADING_NODE_INDEX 999
#define MAX_ORDER_INDEX    10

@interface GameLoadMgr(Private)
-(void) runLoading;
-(void) handleTimer:(NSTimer*)timer;	
@end

@implementation GameLoadMgr

@synthesize delegate;

-(id) init
{
	return [self initWithLoadingStyle:LADOING_LAYER_RESOURCE];
}

-(id) initWithLoadingStyle:(LoadingStyle) style;
{
	if ((self = [super init]))
	{
		self.delegate = nil;
		m_nPrecent = 0;
		m_enStyle = style;
		
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"loading-data.plist"]; 	
	}
	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(void) runLoading
{
	// add black background
	CCLayerColor *lc = [CCLayerColor layerWithColor:ccc4(52,52,52,255)];
	[delegate addChild:lc z:MAX_ORDER_INDEX tag:LOADING_NODE_INDEX];
	
	// add action for sprite
	NSMutableArray *loadArray = [NSMutableArray array];
	for(int i = 1; i <= 12; i++) 
	{
		[loadArray addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"loading-%d.png", i]]];
	}
	CCAnimation *loadAAnimation = [CCAnimation animationWithFrames:loadArray delay:CCRANDOM_0_1()];
	CCAction* loadAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:loadAAnimation restoreOriginalFrame:NO]];
	
	CCSprite* loadSprite = [CCSprite spriteWithSpriteFrameName:@"loading-1.png"];        
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	loadSprite.position = ccp(winSize.width/2,winSize.height/2);
	[delegate addChild:loadSprite z:MAX_ORDER_INDEX+1 tag:LOADING_NODE_INDEX+1];
	[loadSprite runAction:loadAction];
}

-(void) handleTimer:(NSTimer*)timer
{
	m_nPrecent += 10;
	
	if (m_nPrecent > 100) 
	{
		// stop timer
		[timer invalidate];
		
		// notify delegate end load
		if ([delegate respondsToSelector:@selector(willEndLoading)]) 
			[delegate performSelector:@selector(willEndLoading)];
		
		// resume precent
		m_nPrecent = 0;
		
		// remove loading animate
		[delegate removeChildByTag:LOADING_NODE_INDEX cleanup:YES];
		[delegate removeChildByTag:LOADING_NODE_INDEX+1 cleanup:YES];
	}
	
	// notify delegate
	NSNumber *number = [NSNumber numberWithInt:m_nPrecent];
	[delegate performSelector:@selector(doLoading:) withObject:number];
}

- (void) beginLoading
{ 
    if ([delegate conformsToProtocol:@protocol(GameLoadDelegate)] &&
		[delegate respondsToSelector:@selector(doLoading:)])
	{ 
		// add loading animate
		[self runLoading];
		
		// notify delegate begin load
		if ([delegate respondsToSelector:@selector(willBeginLoading)]) 
			[delegate performSelector:@selector(willBeginLoading)];
		
		// add background timer
		NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1f
												 target:self
											   selector:@selector(handleTimer:)
											   userInfo:nil
												repeats:YES];
		[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	} 
}

@end