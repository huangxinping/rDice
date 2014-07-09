//
//  GameChoiceScene.m
//  rDice
//
//  Created by o0402 on 11-7-11.
//  Copyright 2011 inblue. All rights reserved.
//

#import "GameChoiceScene.h"
#import "GameLayerScene.h"
#import "SimpleAudioEngine.h"
#import "GamePlayScene.h"
#import "OFAchievementService.h"
#import "OFDelegate.h"

@interface GameChoiceScene(privateMethods)
- (CCMenuItem*)itemWithPlistFrame:(NSString*)value selectedImage:(NSString*)value2 target:(id)t selector:(SEL)s;
- (CCMenuItem*)itemWithPlistFrame:(NSString*)value selectedImage:(NSString*)value2;
- (void)createMenuButton:(NSString*)text fontfnt:(NSString*)fnt selector:(SEL)sel tag:(int)t scale:(float)s point:(CGPoint)p isEnabled:(BOOL)enable;
@end

@implementation GameChoiceScene

+(id) scene
{
	CCScene *scene = [CCScene node];	
	GameChoiceScene *layer = [GameChoiceScene node];
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

-(void) createMenuButton:(NSString*)text fontfnt:(NSString*)fnt selector:(SEL)sel tag:(int)t scale:(float)s point:(CGPoint)p isEnabled:(BOOL)enable
{
	CCLabelBMFont *BMFont = [CCLabelBMFont labelWithString:text fntFile:fnt];
	CCMenuItemLabel *menuLabel = [CCMenuItemLabel itemWithLabel:BMFont target:self selector:sel];
	menuLabel.position = ccp(p.x, p.y);
	menuLabel.color = ccBLACK;
	menuLabel.scale = s;
	menuLabel.tag = t;
	[menuLabel setIsEnabled:enable];
	CCMenu *menu = [CCMenu menuWithItems:menuLabel,nil]; // toggle must add to menu!
	menu.position = ccp(0, 0);
	[self addChild:menu z:0 tag:t];
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
			
			CCLabelBMFont *gameStyleEasy = [CCLabelBMFont labelWithString:@"Easy" fntFile:@"ShapeFont.fnt"];
			gameStyleEasy.position = ccp(50.0f, 300.0f);
			gameStyleEasy.color = ccBLACK;
			[self addChild:gameStyleEasy];
			
			CCLabelBMFont *gameStyleMedium = [CCLabelBMFont labelWithString:@"Medium" fntFile:@"ShapeFont.fnt"];
			gameStyleMedium.position = ccp(160.0f, 300.0f);
			gameStyleMedium.color = ccBLACK;
			[self addChild:gameStyleMedium];
			
			CCLabelBMFont *gameStyleHard = [CCLabelBMFont labelWithString:@"Hard" fntFile:@"ShapeFont.fnt"];
			gameStyleHard.position = ccp(270.0f, 300.0f);
			gameStyleHard.color = ccBLACK;
			[self addChild:gameStyleHard];
			
			// stage chioce button
			float fDistanceStep = 45.0f;
			for (int j = 0; j < 7; j++)
				for (int i = 0; i < 5; i++)
				{
					// back rectangle
					CCSprite *spriteRectangle = [CCSprite spriteWithSpriteFrameName:@"black_rect.png"];
					spriteRectangle.position = ccp(25.0f+j*fDistanceStep, 250.0f-40.0f*i);
					[self addChild:spriteRectangle];
					
					// stage number
					NSString *buffer = [NSString stringWithFormat:@"%d",j*5+i+1];	
					BOOL enable = NO;
					if ((j*5+i+1) >= 1 && (j*5+i+1) < 11) 
					{
						int easyLevel = [[NSUserDefaults standardUserDefaults] integerForKey:@"EasyLevel"];
						if ((j*5+i+1) <= easyLevel) 
							enable = YES;
					}
					else if ((j*5+i+1) >= 11 && (j*5+i+1) < 26)
					{
						int mediumLevel = [[NSUserDefaults standardUserDefaults] integerForKey:@"MediumLevel"];
						if ((j*5+i+1) <= mediumLevel) 
							enable = YES;
					}
					else if ((j*5+i+1) >= 26 && (j*5+i+1) < 36)
					{
						int hardLevel = [[NSUserDefaults standardUserDefaults] integerForKey:@"HardLevel"];
						if ((j*5+i+1) <= hardLevel) 
							enable = YES;
					}
					
					if (enable == YES) 
					{
						CCSprite *star = [CCSprite spriteWithSpriteFrameName:@"level_star.png"];
						star.position = ccp(25.0f+j*fDistanceStep, 250.0f-40.0f*i);
						[self addChild:star];
					}
					
					[self createMenuButton:buffer 
								   fontfnt:@"ShapeFont.fnt" 
								  selector:@selector(playGame:) 
									   tag:j*5+i+1 scale:1.0 
									 point:ccp(25.0f+j*fDistanceStep, 250.0f-40.0f*i) 
								  isEnabled:enable];
				}
			
			// GamingNews control button
			[self createMenuButton:@"Gaming News" 
						   fontfnt:@"ShapeFont.fnt" 
						  selector:@selector(gamingNews:) 
							   tag:0 scale:0.5f 
							 point:ccp(63.0f, 20.0f)
						  isEnabled:YES];
			
			// PlayMoreGames control button
			[self createMenuButton:@"Play More Games" 
						   fontfnt:@"ShapeFont.fnt" 
						  selector:@selector(playMoreGames:) 
							   tag:1 
							 scale:0.5f 
							 point:ccp(240.0f, 20.0f)
						  isEnabled:YES];
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

- (void) playGame:(id) sender 
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"buttonsound.mp3"];
	
	[OFAchievementService updateAchievement:@"1086952" 
						 andPercentComplete:100.0f 
						andShowNotification:YES 
								  onSuccess:OFDelegate() 
								  onFailure:OFDelegate()];
	
	CCMenuItemLabel *node = (CCMenuItemLabel*)sender;
	CCScene *scene = [GamePlayScene scene:node.tag];
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
