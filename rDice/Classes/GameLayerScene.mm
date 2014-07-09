//
//  HelloWorldLayer.m
//  rDice
//
//  Created by o0402 on 11-7-11.
//  Copyright inblue 2011. All rights reserved.
//

// Import the interfaces
#import "GameLayerScene.h"
#import "SimpleAudioEngine.h"
#import "GameCreditsScene.h"
#import "GameChoiceScene.h"
#import "OpenFeint.h"

@interface GameLayerScene(privateMethods)
- (CCMenuItem*)itemWithPlistFrame:(NSString*)value selectedImage:(NSString*)value2 target:(id)t selector:(SEL)s;
- (CCMenuItem*)itemWithPlistFrame:(NSString*)value selectedImage:(NSString*)value2;
- (void)createMenuButton:(NSString*)text fontfnt:(NSString*)fnt selector:(SEL)sel tag:(int)t scale:(float)s point:(CGPoint)p;
@end

@implementation GameLayerScene

+(id) scene
{
	CCScene *scene = [CCScene node];	
	GameLayerScene *layer = [GameLayerScene node];
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

- (void) doLoading:(NSNumber*)precent
{
	int nPrecent = [precent intValue];
	switch (nPrecent) 
	{
		case 10:
		{
			[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"gamepic.plist"];
			
			ptBackgroundDice = ccp(0,0);
			
			CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"background.png"];
			background.position = ccp(160, 240);
			[self addChild:background z:0 tag:BACKGROUND];
			
			CCSprite *logo = [CCSprite spriteWithSpriteFrameName:@"logo.png"];
			logo.position = ccp(160, 240);
			[self addChild:logo z:0 tag:LOGO];
			CCScaleBy *sb = [CCScaleBy actionWithDuration:0.2f scale:1.5f];
			CCSequence *seq = [CCSequence actions:sb,[sb reverse],nil];
			CCEaseInOut *ei = [CCEaseInOut actionWithAction:seq rate:1.0f];
			[logo runAction:ei];
			break;
		}
		case 30:
		{
			// dice sprite in background
			for (int i = 1; i <= 6; i++)
			{
				NSString *stringDice = [NSString stringWithFormat:@"dice_%d.png", i];
				CCSprite *spriteDice = [CCSprite spriteWithSpriteFrameName:stringDice];
				spriteDice.position = ccp(-50, -50);
				spriteDice.opacity = 128;
				[self addChild:spriteDice z:0 tag:MIN_DICE_INDEX+i];
			}
			break;
		}
		case 50:
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
			
			// game text
			CCLabelBMFont *gameName = [CCLabelBMFont labelWithString:@"enDice" fntFile:@"ShapeFont.fnt"];
			gameName.position = ccp(160.0f, 380.0f);
			gameName.color = ccBLACK;
			gameName.scale = 2.0f;
			[self addChild:gameName];
			
			// play control button
			[self createMenuButton:@"Play" fontfnt:@"ShapeFont.fnt" selector:@selector(playGame:) tag:PLAYGAME scale:1.0f point:ccp(160.0f,200.0f)];
			
			// credits control button
			[self createMenuButton:@"Credits" fontfnt:@"ShapeFont.fnt" selector:@selector(CreditsHelp:) tag:CREDITS scale:1.0f point:ccp(160.0f,150.0f)];
			
			// GamingNews control button
			[self createMenuButton:@"Gaming News" fontfnt:@"ShapeFont.fnt" selector:@selector(gamingNews:) tag:GAMEINGNEWS scale:0.5f point:ccp(63.0f,20.0f)];
			
			// PlayMoreGames control button
			[self createMenuButton:@"Play More Games" fontfnt:@"ShapeFont.fnt" selector:@selector(playMoreGames:) tag:PLAYMOREGAMES scale:0.5f point:ccp(240.0f,20.0f)];
			
			[self schedule:@selector(updateBackgroundDice:) interval:1.0f];
			break;
		}	
		case 100:
		{
			CCMenuItem *of = [self itemWithPlistFrame:@"openfeint_button.png" 
										selectedImage:@"openfeint_button_down.png"
											   target:self
											 selector:@selector(lauchedOpenFeint:)];
			of.position = ccp(160.0f,100.0f);
			CCMenu *menu = [CCMenu menuWithItems:of,nil];
			menu.position = ccp(0,0);
			[self addChild:menu];
			break;
		}
		default:
			break;
	}
}

-(void) lauchedOpenFeint:(id)sender
{
	[OpenFeint launchDashboard];
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

- (void) CreditsHelp:(id) sender 
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"buttonsound.mp3"];
	
	CCScene *scene = [GameCreditsScene scene];
	[[CCDirector sharedDirector] replaceScene:scene];
}

- (void) playGame:(id) sender 
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"buttonsound.mp3"];
	
	CCScene *scene = [GameChoiceScene scene];
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

- (void) removeLogo:(id) sender
{
	[self removeChildByTag:LOGO cleanup:YES];
}

- (void) releaseLogo
{
	CCFadeOut *fo = [CCFadeOut actionWithDuration:1.0f];
	CCCallFuncN *cf = [CCCallFuncN actionWithTarget:self selector:@selector(removeLogo:)];
	CCSequence *seq = [CCSequence actions:fo,cf,nil];
	CCNode *node = (CCNode*)[self getChildByTag:LOGO];
	[node runAction:seq];
}

- (void) updateBackgroundDice:(ccTime) dt
{
	// stop schedule
	[self unschedule:@selector(updateBackgroundDice:)];
	
	// remove logo
	[self releaseLogo];
	
	// run action with dice
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	CCSprite *node = (CCSprite*)[self getChildByTag:MIN_DICE_INDEX+rand()%6+1];
	CGPoint pt;
	if (ptBackgroundDice.x == 0 && ptBackgroundDice.y == 0)
		pt = node.position;
	else
		pt = ptBackgroundDice;
	int speedDirX = 1;
	int speedDirY = 1;
	if (pt.x > winSize.width/2)
		speedDirX = -1;
	if (pt.y > winSize.height/2)
		speedDirY = -1;
	node.position = pt;
	CCSequence *seq = [CCSequence actions:
										[CCMoveBy actionWithDuration:0.5f position:ccp(speedDirX*rand()%50+10.0f,speedDirY*rand()%50+10.0f)],
										[CCCallFuncN actionWithTarget:self selector:@selector(judgeDice:)],
										nil
					   ];
	CCRepeatForever *rf = [CCRepeatForever actionWithAction:seq];
	[node runAction:rf];
}

// Judgment direction for dice
- (void) judgeDice:(id) sender
{
	CCSprite *sprite = (CCSprite*)sender;
	CGPoint pt = sprite.position; 
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	if (pt.x > (winSize.width+sprite.contentSize.width/2)|| 
		pt.x < -(sprite.contentSize.width/2)|| 
		pt.y > winSize.height+(sprite.contentSize.height/2) || 
		pt.y < -((sprite.contentSize.height/2))) // out of screen
	{
		ptBackgroundDice = ccp(pt.x, pt.y);// save position
		[sprite stopAllActions];
		[self schedule:@selector(updateBackgroundDice:) interval:1.0f];
	}
}

@end
