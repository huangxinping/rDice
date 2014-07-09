//
//  GameCreditsScene.m
//  rDice
//
//  Created by o0402 on 11-7-11.
//  Copyright 2011 inblue. All rights reserved.
//

#import "GameCreditsScene.h"
#import "GameLayerScene.h"
#import "SimpleAudioEngine.h"

@interface GameCreditsScene(privateMethods)
- (CCMenuItem*)itemWithPlistFrame:(NSString*)value selectedImage:(NSString*)value2 target:(id)t selector:(SEL)s;
- (CCMenuItem*)itemWithPlistFrame:(NSString*)value selectedImage:(NSString*)value2;
- (void)createMenuButton:(NSString*)text fontfnt:(NSString*)fnt selector:(SEL)sel tag:(int)t scale:(float)s point:(CGPoint)p;
- (void) insertCreditsText:(NSString*)text point:(CGPoint)p;
@end

@implementation GameCreditsScene

+(id) scene
{
	CCScene *scene = [CCScene node];	
	GameCreditsScene *layer = [GameCreditsScene node];
	[scene addChild: layer];	
	return scene;
}

-(id) init
{
	if( (self=[super init] ))
	{
		m_pGameLoadMgr = [[GameLoadMgr alloc] initWithLoadingStyle:LADOING_LAYER_RESOURCE];
		m_pGameLoadMgr.delegate = self;
	}
	return self;
}

- (void) dealloc
{
	[m_pGameLoadMgr release];
	[super dealloc];
}

- (CCMenuItem*)itemWithPlistFrame:(NSString*)value selectedImage:(NSString*)value2 target:(id)t selector:(SEL)s
{
	CCSprite *normalFrame = [CCSprite spriteWithSpriteFrameName:value];
	CCSprite *selectedFrame = [CCSprite spriteWithSpriteFrameName:value2];
	CCMenuItem *menuItem = [CCMenuItemSprite itemFromNormalSprite:normalFrame
												   selectedSprite:selectedFrame
														   target:t
														 selector:s];
	return menuItem;
}

- (CCMenuItem*)itemWithPlistFrame:(NSString*)value selectedImage:(NSString*)value2
{
	CCSprite *normalFrame = [CCSprite spriteWithSpriteFrameName:value];
	CCSprite *selectedFrame = [CCSprite spriteWithSpriteFrameName:value2];
	CCMenuItem *menuItem = [CCMenuItemSprite itemFromNormalSprite:normalFrame
												   selectedSprite:selectedFrame];
	return menuItem;
}

-(void) createMenuButton:(NSString*)text fontfnt:(NSString*)fnt selector:(SEL)sel tag:(int)t scale:(float)s point:(CGPoint)p
{
	CCLabelBMFont *BMFont = [CCLabelBMFont labelWithString:text fntFile:fnt];
	CCMenuItemLabel *menuLabel = [CCMenuItemLabel itemWithLabel:BMFont target:self selector:sel];
	menuLabel.position = ccp(p.x, p.y);
	menuLabel.color = ccBLACK;
	menuLabel.scale = s;
	CCMenu *menu = [CCMenu menuWithItems:menuLabel,nil]; // toggle must add to menu!
	menu.position = ccp(0, 0);
	[self addChild:menu z:0 tag:t];
}

- (void) insertCreditsText:(NSString*)text point:(CGPoint)p
{
	CCLabelBMFont *BMFont = [CCLabelBMFont labelWithString:text fntFile:@"ShapeFont.fnt"];
	BMFont.position = p;
	BMFont.color = ccBLACK;
	BMFont.scale = 0.5f;
	[self addChild:BMFont];
}

- (void) doLoading:(NSNumber*)precent
{
	int nPrecent = [precent intValue];
	switch (nPrecent) 
	{
		case 10:
		{
			CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"background.png"];
			background.position = ccp(160, 240);
			[self addChild:background z:0 tag:BACKGROUND];
			break;
		}
		case 30:
		{
			// sound contorl button
			CCMenuItem *miUnMute = [self itemWithPlistFrame:@"unmute.png" selectedImage:@"unmute.png"];
			CCMenuItem *miMute = [self itemWithPlistFrame:@"mute.png" selectedImage:@"mute.png"];
			CCMenuItemToggle *mitSound = [CCMenuItemToggle itemWithTarget:self  
																 selector:@selector(muteButtonTapped:)
																	items:miUnMute,miMute,nil];
			mitSound.position = ccp(20, 460);
			CCMenu *menuSound = [CCMenu menuWithItems:mitSound,nil]; // toggle must add to menu!
			menuSound.position = ccp(0, 0);
			[self addChild:menuSound z:0 tag:SOUNDCONTROL];
			BOOL bMute	= [[NSUserDefaults standardUserDefaults] boolForKey:@"MuteControl"];
			[mitSound setSelectedIndex:bMute];
			
			// backmenu control button
			CCMenuItem *backMenu = [self itemWithPlistFrame:@"backmenu.png" 
													selectedImage:@"backmenu.png" 
														   target:self 
														 selector:@selector(menuBack:)];
			backMenu.position = ccp(295.0f, 453.0f);
			backMenu.scale = 0.5f;
			CCMenu *menuBack = [CCMenu menuWithItems:backMenu,nil];
			menuBack.position = ccp(0, 0);
			[self addChild:menuBack];
			
			// game text
			CCLabelBMFont *gameName = [CCLabelBMFont labelWithString:@"enDice" fntFile:@"ShapeFont.fnt"];
			gameName.position = ccp(160.0f, 380.0f);
			gameName.color = ccBLACK;
			gameName.scale = 2.0f;
			[self addChild:gameName];
			
			[self insertCreditsText:@"Created By ...... Ozzie Mercado" point:ccp(160.0f, 300.0f)];
			[self insertCreditsText:@"Menu Music By ...... Zadamanim" point:ccp(160.0f, 270.0f)];
			[self insertCreditsText:@"Game Music By ...... Smad" point:ccp(160.0f, 240.0f)];
			[self insertCreditsText:@"Special Thanks" point:ccp(160.0f, 180.0f)];
			[self insertCreditsText:@"My Family" point:ccp(160.0f, 150.0f)];
			[self insertCreditsText:@"Jackie" point:ccp(160.0f, 120.0f)];
			[self insertCreditsText:@"ArmorGames.com" point:ccp(160.0f, 90.0f)];
			
			// GamingNews control button
			[self createMenuButton:@"Gaming News" fontfnt:@"ShapeFont.fnt" selector:@selector(gamingNews:) tag:0 scale:0.5f point:ccp(63.0f, 20.0f)];
			
			// PlayMoreGames control button
			[self createMenuButton:@"Play More Games" fontfnt:@"ShapeFont.fnt" selector:@selector(playMoreGames:) tag:1 scale:0.5f point:ccp(240.0f, 20.0f)];
			break;
		}
		case 50:
		{
			break;
		}	
		case 100:
		{
			break;
		}
		default:
			break;
	}
}

- (void)onEnter 
{	
    [super onEnter];
	
	[m_pGameLoadMgr beginLoading];
}

- (void) muteButtonTapped:(id) sender 
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"buttonsound.mp3"];
	
	CCMenuItemToggle *node = (CCMenuItemToggle*)sender;
	if ([node selectedIndex] == 0)
	{
		[[SimpleAudioEngine sharedEngine] setMute:NO];
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"MuteControl"];
	}
	else // mute
	{
		[[SimpleAudioEngine sharedEngine] setMute:YES];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MuteControl"];
	}
}

- (void) menuBack:(id) sender 
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"buttonsound.mp3"];
	
	CCScene *scene = [GameLayerScene scene];
	[[CCDirector sharedDirector] replaceScene:scene];
}

- (void) gamingNews:(id) sender 
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"buttonsound.mp3"];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.armorgames.com/"]];
}

- (void) playMoreGames:(id) sender 
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"buttonsound.mp3"];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.armorgames.com/"]];
}

@end
