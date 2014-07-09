//
//  GamePlayScene.m
//  rDice
//
//  Created by o0402 on 11-7-11.
//  Copyright 2011 inblue. All rights reserved.
//

#import "GamePlayScene.h"
#import "SimpleAudioEngine.h"
#import "GameLayerScene.h"
#import "TBXML.h"
#import "OFHighScoreService.h"
#import "OFDelegate.h"

@interface GamePlayScene(privateMethods)
- (CCMenuItem*)itemWithPlistFrame:(NSString*)value selectedImage:(NSString*)value2 target:(id)t selector:(SEL)s;
- (CCMenuItem*)itemWithPlistFrame:(NSString*)value selectedImage:(NSString*)value2;
- (void) insertDescriptionText:(NSString*)text point:(CGPoint)p;
- (void)createMenuButton:(NSString*)text fontfnt:(NSString*)fnt selector:(SEL)sel tag:(int)t scale:(float)s point:(CGPoint)p;
-(id) initWithStage:(int)level;
-(void) getPlayData:(int)level;
@end

@implementation GamePlayScene

@synthesize levelCurrentPlay = levelCurrentPlay_;

+(id) scene:(int)stage
{
	CCScene *scene = [CCScene node];	
	GamePlayScene *layer = [[GamePlayScene alloc] initWithStage:stage];
	[scene addChild: layer];	
	return scene;
}

-(id) initWithStage:(int)level
{
	if( (self=[super init] ))
	{
		NSAssert(level>0&&level<=35,@"stage not in range!!!");
		
		self.isTouchEnabled = YES;
		self.levelCurrentPlay = level;
		m_pMoveDiceArray = [[NSMutableArray alloc] init];
		m_pDiceCurTouched = nil;
		m_nMoveDirection = -10;
		for (int i = 0; i < MAX_ARRAY_X; i++) 
			for (int j = 0; j < MAX_ARRAY_Y; j++) 
			{
				m_nDiceMapArray[i][j] = BLOCK_EMPTY_DICE;
			}
		m_pTargerArray = [[NSMutableArray alloc] init];
		m_bCanTouched = YES;
		
		m_pGameLoadMgr = [[GameLoadMgr alloc] initWithLoadingStyle:LADOING_LAYER_RESOURCE];
		m_pGameLoadMgr.delegate = self;
	}
	return self;
}

- (void) dealloc
{
	[m_pGameLoadMgr release];
	[m_pTargerArray release];
	for (CCSprite *node in m_pMoveDiceArray) [node release];
	for (CCSprite *node in m_pTargerArray) [node release];
	[m_pMoveDiceArray release];
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

- (void) insertDescriptionText:(NSString*)text point:(CGPoint)p
{
	CCLabelBMFont *BMFont = [CCLabelBMFont labelWithString:text fntFile:@"ShapeFont.fnt"];
	BMFont.position = p;
	BMFont.color = ccBLACK;
	BMFont.scale = 0.5f;
	[self addChild:BMFont];
	[BMFont runAction:[CCFadeIn actionWithDuration:2.0f]];
}

-(void) createMenuButton:(NSString*)text fontfnt:(NSString*)fnt selector:(SEL)sel tag:(int)t scale:(float)s point:(CGPoint)p
{
	CCLabelBMFont *BMFont = [CCLabelBMFont labelWithString:text fntFile:fnt];
	CCMenuItemLabel *menuLabel = [CCMenuItemLabel itemWithLabel:BMFont target:self selector:sel];
	menuLabel.position = ccp(p.x, p.y);
	menuLabel.color = ccWHITE;
	menuLabel.scale = s;
	CCMenu *menu = [CCMenu menuWithItems:menuLabel,nil]; // toggle must add to menu!
	menu.position = ccp(0, 0);
	[self addChild:menu z:0 tag:t];
}

-(void) getPlayData:(int)level
{
	TBXML *tbxml = [[TBXML tbxmlWithXMLFile:[NSString stringWithFormat:@"lv%d.xml",level]] retain];
	TBXMLElement *root = tbxml.rootXMLElement;
	if (root) 
	{
		// search level description
		TBXMLElement *blockElement = [TBXML childElementNamed:@"description" parentElement:root];
		while (blockElement != nil) 
		{
			TBXMLElement *blockAttribute = [TBXML childElementNamed:@"attribute" parentElement:blockElement];
			while (blockAttribute != nil) 
			{
				CGPoint pt = ccp(0,0);
				NSString *description = nil;
			
				NSString *p1 = [TBXML valueOfAttributeNamed:@"p1" forElement:blockAttribute];
				NSString *p2 = [TBXML valueOfAttributeNamed:@"p2" forElement:blockAttribute];
				NSString *text = [TBXML valueOfAttributeNamed:@"text" forElement:blockAttribute];
				
				// convert data to game level info
				pt = ccp([p1 floatValue],[p2 floatValue]);
				description = [text retain];
				
				// add text CCLayer node
				[self insertDescriptionText:description point:pt];
				
				// release node
				[description release];
			
				blockAttribute = [TBXML nextSiblingNamed:@"attribute" searchFromElement:blockAttribute];
			}
			blockElement = [TBXML nextSiblingNamed:@"description" searchFromElement:blockElement];
		}
		
		// search level play data
		blockElement = [TBXML childElementNamed:@"level" parentElement:root];
		while (blockElement != nil)
		{
			TBXMLElement *blockAttribute = [TBXML childElementNamed:@"unmove" parentElement:blockElement];
			while (blockAttribute != nil) 
			{
				CGPoint targetXY = ccp(0,0);
				
				NSString *x = [TBXML valueOfAttributeNamed:@"x" forElement:blockAttribute];
				NSString *y = [TBXML valueOfAttributeNamed:@"y" forElement:blockAttribute];
				
				// convert data to game level info
				targetXY = ccp([x intValue],[y intValue]);
				
				// insert level data to current layer
				GameTargetSprite *target = [GameTargetSprite spriteWithSpriteFrameName:@"dot_rect.png"];
				target.position = ccp(targetXY.x*50+10,abs((targetXY.y-8)*50)+15);
				target.anchorPoint = ccp(0,0);
				target.diceX = targetXY.x;
				target.diceY = targetXY.y;
				[self addChild:target];
				
				// save target postion
				[m_pTargerArray addObject:[target retain]];
				
				// search next sibelement
				blockAttribute = [TBXML nextSiblingNamed:@"unmove" searchFromElement:blockAttribute];
			}
			
			blockAttribute = [TBXML childElementNamed:@"move" parentElement:blockElement];
			while (blockAttribute != nil) 
			{
				CGPoint diceXY = ccp(0,0);
				NSInteger size = 0;
				
				NSString *x = [TBXML valueOfAttributeNamed:@"x" forElement:blockAttribute];
				NSString *y = [TBXML valueOfAttributeNamed:@"y" forElement:blockAttribute];
				NSString *s = [TBXML valueOfAttributeNamed:@"s" forElement:blockAttribute];
				
				// convert data to game level info
				diceXY = ccp([x intValue],[y intValue]);
				size = [s intValue];
				
				// insert level data to current layer
				NSString *buffer = [NSString stringWithFormat:@"dice_%@.png",s];
				GameDiceSprite *dice = [GameDiceSprite spriteWithSpriteFrameName:buffer];
				dice.position = ccp(diceXY.x*50+10,abs((diceXY.y-8)*50)+15);
				dice.anchorPoint = ccp(0,0);
				dice.scale = 0.5f;
				dice.diceCur = dice.diceOld = size;
				dice.diceX = dice.diceOldX = diceXY.x;
				dice.diceY = dice.diceOldY = diceXY.y;
				[self addChild:dice];
				
				// save changeable data
				m_nDiceMapArray[dice.diceX][dice.diceY] = dice.diceCur;
				[m_pMoveDiceArray addObject:[dice retain]];
				
				// search next sibelement
				blockAttribute = [TBXML nextSiblingNamed:@"move" searchFromElement:blockAttribute];
			}
			
			
			blockElement = [TBXML nextSiblingNamed:@"level" searchFromElement:blockElement];
		}
	}
	
	// release resources
	[tbxml release];
}

-(void) retryGame:(id) sender
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"buttonsound.mp3"];
	
	int levelCurrentPlay = self.levelCurrentPlay;
	CCScene *scene = [GamePlayScene scene:levelCurrentPlay];
	[[CCDirector sharedDirector] replaceScene:scene];
}

-(void) nextGame:(id) sender
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"buttonsound.mp3"];
	
	int levelCurrentPlay = self.levelCurrentPlay;
	CCScene *scene = [GamePlayScene scene:levelCurrentPlay+1];
	[[CCDirector sharedDirector] replaceScene:scene];
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
			
			m_pMoveShowRect = [CCSprite spriteWithSpriteFrameName:@"move_rect.png"];
			m_pMoveShowRect.position = ccp(-100,-100);
			m_pMoveShowRect.anchorPoint = ccp(0,0);
			[self addChild:m_pMoveShowRect z:1 tag:MOVE_RECT_INDEX];
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
			
			// undo control button
			CCMenuItem *undoMenu = [self itemWithPlistFrame:@"undo_button.png" 
											  selectedImage:@"undo_button.png" 
													 target:self 
												   selector:@selector(undoRun:)];
			undoMenu.position = ccp(258.0f, 453.0f);
			undoMenu.scale = 0.5f;
			CCMenu *undoBack = [CCMenu menuWithItems:undoMenu,nil];
			undoBack.position = ccp(0, 0);
			undoBack.visible = NO;
			[undoBack setIsTouchEnabled:NO];
			[self addChild:undoBack];
			
			// reset control button
			CCMenuItem *resetMenu = [self itemWithPlistFrame:@"reset_button.png" 
											  selectedImage:@"reset_button.png" 
													 target:self 
												   selector:@selector(resetRun:)];
			resetMenu.position = ccp(221.0f, 453.0f);
			resetMenu.scale = 0.5f;
			CCMenu *resetBack = [CCMenu menuWithItems:resetMenu,nil];
			resetBack.position = ccp(0, 0);
			[self addChild:resetBack];
			
			// show stage label
			NSString *buffer = [NSString stringWithFormat:@"Level:%02d", self.levelCurrentPlay];
			CCLabelBMFont *levelBMFont = [CCLabelBMFont labelWithString:buffer fntFile:@"ShapeFont.fnt"];
			levelBMFont.position = ccp(70.0f, 25.0f);
			levelBMFont.color = ccBLACK;
			[self addChild:levelBMFont];
			break;
		}
		case 50:
		{
			[self getPlayData:self.levelCurrentPlay];
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

- (void) undoRun:(id) sender 
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"buttonsound.mp3"];
}

- (void) resetRun:(id) sender 
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"buttonsound.mp3"];
	
	int levelCurrentPlay = self.levelCurrentPlay;
	CCScene *scene = [GamePlayScene scene:levelCurrentPlay];
	[[CCDirector sharedDirector] replaceScene:scene];
}

-(BOOL) judgeGameWin
{
	BOOL isGameWin = YES;
	
	// judge location in target postion
	for (GameTargetSprite *target in m_pTargerArray) 
	{
		int nCount = 0;
		for (GameDiceSprite *dice in m_pMoveDiceArray) 
		{
			if (dice.diceX == target.diceX && dice.diceY == target.diceY) 
			{
				nCount++;
			}
		}
		if (nCount == 0) 
		{
			isGameWin = NO;
			break;
		}
	}
	
	// judge dice number is zero
	for (GameDiceSprite *dice in m_pMoveDiceArray)
	{
		if (dice.diceCur != 0) 
		{
			isGameWin = NO;
			break;
		}
	}
	if (isGameWin)
	{
		if (self.levelCurrentPlay >= 1 && self.levelCurrentPlay < 11) 
		{
			[[NSUserDefaults standardUserDefaults] setInteger:self.levelCurrentPlay+1 forKey:@"EasyLevel"];
		}
		else if (self.levelCurrentPlay >= 11 && self.levelCurrentPlay < 26)
		{
			[[NSUserDefaults standardUserDefaults] setInteger:self.levelCurrentPlay+1 forKey:@"MediumLevel"];
		}
		else if (self.levelCurrentPlay >= 26 && self.levelCurrentPlay < 36)
		{
			[[NSUserDefaults standardUserDefaults] setInteger:self.levelCurrentPlay+1 forKey:@"HardLevel"];
		}
		
		CCLayerColor* colorLayer = [CCColorLayer layerWithColor:ccc4(0, 0, 0, 128)];
		[self addChild:colorLayer];
		
		[self createMenuButton:@"retry" fontfnt:@"ShapeFont.fnt" selector:@selector(retryGame:) tag:0 scale:1.0f point:ccp(100.0f, 240.0f)];
		[self createMenuButton:@"next" fontfnt:@"ShapeFont.fnt" selector:@selector(nextGame:) tag:0 scale:1.0f point:ccp(220.0f, 240.0f)];
		
		[[SimpleAudioEngine sharedEngine] playEffect:@"winsound.mp3"];
		
		[OFHighScoreService setHighScore:self.levelCurrentPlay forLeaderboard:@"794076" onSuccess:OFDelegate() onFailure:OFDelegate()];
		return YES;
	}
	return NO;
}

-(BOOL) judgeGameOver
{
	BOOL isGameOver = YES;
	for (GameDiceSprite *dice in m_pMoveDiceArray)
	{
		if (dice.diceCur != 0) 
		{
			isGameOver = NO;
			break;
		}
	}
	if (isGameOver) 
	{
		CCLayerColor* colorLayer = [CCColorLayer layerWithColor:ccc4(0, 0, 0, 128)];
		[self addChild:colorLayer];
		
		[self createMenuButton:@"retry" fontfnt:@"ShapeFont.fnt" selector:@selector(retryGame:) tag:0 scale:1.0f point:ccp(160.0f, 240.0f)];
		
		[[SimpleAudioEngine sharedEngine] playEffect:@"zonesound.mp3"];
		return YES;
	}
	return NO;
}

-(void) updateTouchedDice:(id) sender
{
	NSString *buffer = [NSString stringWithFormat:@"dice_%d.png",m_pDiceCurTouched.diceCur-1];
	CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:buffer];
	if (frame) 
	{
		[m_pDiceCurTouched setDisplayFrame:frame];
		
		// set last dice'index in map
		m_nDiceMapArray[m_pDiceCurTouched.diceX][m_pDiceCurTouched.diceY] = BLOCK_EMPTY_DICE;
		
		// change now dice'index
		m_pDiceCurTouched.diceCur = m_pDiceCurTouched.diceCur-1;
		
		switch (m_nMoveDirection) 
		{
			case MOVE_LEFT:
				m_pDiceCurTouched.diceX = m_pDiceCurTouched.diceX - 1;
				break;
			case MOVE_RIGHT:
				m_pDiceCurTouched.diceX = m_pDiceCurTouched.diceX + 1;
				break;
			case MOVE_TOP:
				m_pDiceCurTouched.diceY = m_pDiceCurTouched.diceY - 1;
				break;
			case MOVE_BOTTOM:
				m_pDiceCurTouched.diceY = m_pDiceCurTouched.diceY + 1;
				break;
			default:
				break;
		}
		
		// set now dice'index in map
		m_nDiceMapArray[m_pDiceCurTouched.diceX][m_pDiceCurTouched.diceY] = m_pDiceCurTouched.diceCur;
		
		m_pDiceCurTouched = nil;
		m_nMoveDirection = -10;
		
		[[SimpleAudioEngine sharedEngine] playEffect:@"movesound.mp3"];
	}
	
	if ([self judgeGameWin] == NO) 
	{
		// judge game over
		[self judgeGameOver];	
	}
	
	m_bCanTouched = YES; // set can touched in layer.
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!m_bCanTouched) return;
	UITouch *touch = [touches anyObject];
	CGPoint touchlocation = [touch locationInView:[touch view]];
	touchlocation = [[CCDirector sharedDirector] convertToGL:touchlocation];
	
	m_pDiceCurTouched = nil;
	for (GameDiceSprite* dice in m_pMoveDiceArray)
	{
		CGRect rect = CGRectMake(dice.position.x,dice.position.y,50,50);
		if (CGRectContainsPoint(rect,touchlocation))
		{
			m_pDiceCurTouched = dice;
			break;
		}
	}
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint touchlocation = [touch locationInView:[touch view]];
	touchlocation = [[CCDirector sharedDirector] convertToGL:touchlocation];

	m_pMoveShowRect.position = ccp(-100,-100);
	m_nMoveDirection = -10;
	if (m_pDiceCurTouched != nil && m_pDiceCurTouched.diceCur > 0) 
	{
		CGRect rcL = CGRectMake(m_pDiceCurTouched.position.x-50,m_pDiceCurTouched.position.y,50,50);
		CGRect rcR = CGRectMake(m_pDiceCurTouched.position.x+50,m_pDiceCurTouched.position.y,50,50);
		CGRect rcT = CGRectMake(m_pDiceCurTouched.position.x,m_pDiceCurTouched.position.y+50,50,50);
		CGRect rcB = CGRectMake(m_pDiceCurTouched.position.x,m_pDiceCurTouched.position.y-50,50,50);
		
		if (CGRectContainsPoint(rcL,touchlocation) && m_pDiceCurTouched.diceX >= 0) 
		{
			m_pMoveShowRect.position = ccp(rcL.origin.x,rcL.origin.y);
			m_nMoveDirection = MOVE_LEFT;
			return;
		}
		else if (CGRectContainsPoint(rcR,touchlocation) && m_pDiceCurTouched.diceX < MAX_ARRAY_X-1) 
		{
			m_pMoveShowRect.position = ccp(rcR.origin.x,rcR.origin.y);
			m_nMoveDirection = MOVE_RIGHT;
			return;
		}
		else if (CGRectContainsPoint(rcT,touchlocation) && m_pDiceCurTouched.diceY >= 0) 
		{
			m_pMoveShowRect.position = ccp(rcT.origin.x,rcT.origin.y);
			m_nMoveDirection = MOVE_TOP;
			return;
		}
		else if (CGRectContainsPoint(rcB,touchlocation) && m_pDiceCurTouched.diceY < MAX_ARRAY_Y-1) 
		{
			m_pMoveShowRect.position = ccp(rcB.origin.x,rcB.origin.y);
			m_nMoveDirection = MOVE_BOTTOM;
			return;
		}
	}
}

// return value is NO, will stop current dice and moved action
-(BOOL) judgeCanMovedDice
{
	NSMutableArray *array = [[NSMutableArray alloc] init];
	
	// count whole moved dice form direction
	if (m_nMoveDirection == MOVE_LEFT) 
	{
		int nSearchBeginIndexX = m_pDiceCurTouched.diceX-1;
		int nSearchBeginIndexY = m_pDiceCurTouched.diceY;
		while (true) 
		{
			if (nSearchBeginIndexX < 0) break;
			if (m_nDiceMapArray[nSearchBeginIndexX][nSearchBeginIndexY] == BLOCK_EMPTY_DICE) break;
			for (GameDiceSprite* dice in m_pMoveDiceArray)
			{
				if (dice.diceX == nSearchBeginIndexX && dice.diceY == nSearchBeginIndexY) 
				{
					[array addObject:dice];
					break;
				}
			}
			nSearchBeginIndexX--;
		}	
	}
	else if (m_nMoveDirection == MOVE_RIGHT)
	{
		int nSearchBeginIndexX = m_pDiceCurTouched.diceX+1;
		int nSearchBeginIndexY = m_pDiceCurTouched.diceY;
		while (true) 
		{
			if (nSearchBeginIndexX >= MAX_ARRAY_X) break;
			if (m_nDiceMapArray[nSearchBeginIndexX][nSearchBeginIndexY] == BLOCK_EMPTY_DICE) break;
			for (GameDiceSprite* dice in m_pMoveDiceArray)
			{
				if (dice.diceX == nSearchBeginIndexX && dice.diceY == nSearchBeginIndexY) 
				{
					[array addObject:dice];
					break;
				}
			}
			nSearchBeginIndexX++;
		}
	}
	else if (m_nMoveDirection == MOVE_TOP)
	{
		int nSearchBeginIndexX = m_pDiceCurTouched.diceX;
		int nSearchBeginIndexY = m_pDiceCurTouched.diceY-1;
		while (true) 
		{
			if (nSearchBeginIndexY < 0) break;
			if (m_nDiceMapArray[nSearchBeginIndexX][nSearchBeginIndexY] == BLOCK_EMPTY_DICE) break;
			for (GameDiceSprite* dice in m_pMoveDiceArray)
			{
				if (dice.diceX == nSearchBeginIndexX && dice.diceY == nSearchBeginIndexY) 
				{
					[array addObject:dice];
					break;
				}
			}
			nSearchBeginIndexY--;
		}
	}
	else if (m_nMoveDirection == MOVE_BOTTOM)
	{
		int nSearchBeginIndexX = m_pDiceCurTouched.diceX;
		int nSearchBeginIndexY = m_pDiceCurTouched.diceY+1;
		while (true) 
		{
			if (nSearchBeginIndexY >= MAX_ARRAY_Y) break;
			if (m_nDiceMapArray[nSearchBeginIndexX][nSearchBeginIndexY] == BLOCK_EMPTY_DICE) break;
			for (GameDiceSprite* dice in m_pMoveDiceArray)
			{
				if (dice.diceX == nSearchBeginIndexX && dice.diceY == nSearchBeginIndexY) 
				{
					[array addObject:dice];
					break;
				}
			}
			nSearchBeginIndexY++;
		}
	}
	
	// if one dice in 0, return NO
	if ([array count])
	{
		GameDiceSprite *lastObject = [array lastObject];
		if (m_nMoveDirection == MOVE_LEFT && lastObject.diceX == 0) 
		{
			[array release];
			return NO;
		}
		else if (m_nMoveDirection == MOVE_RIGHT && lastObject.diceX == MAX_ARRAY_X-1)
		{
			[array release];
			return NO;
		}
		else if (m_nMoveDirection == MOVE_TOP && lastObject.diceY == 0)
		{
			[array release];
			return NO;
		}
		else if (m_nMoveDirection == MOVE_BOTTOM && lastObject.diceY == MAX_ARRAY_Y-1)
		{
			[array release];
			return NO;
		}
	
		// move moved dice
		for (int i = [array count]-1; i >= 0; i--) 
		{
			GameDiceSprite *dice = [array objectAtIndex:i];
			
			// set last dice'index in map
			m_nDiceMapArray[dice.diceX][dice.diceY] = BLOCK_EMPTY_DICE;
			
			CGPoint point = ccp(0,0);
			switch (m_nMoveDirection) 
			{
				case MOVE_LEFT:
					dice.diceX = dice.diceX - 1;
					point = ccp(-50,0);
					break;
				case MOVE_RIGHT:
					dice.diceX = dice.diceX + 1;
					point = ccp(50,0);
					break;
				case MOVE_TOP:
					dice.diceY = dice.diceY - 1;
					point = ccp(0,50);
					break;
				case MOVE_BOTTOM:
					dice.diceY = dice.diceY + 1;
					point = ccp(0,-50);
					break;
				default:
					break;
			}
			
			// set now dice'index in map
			m_nDiceMapArray[dice.diceX][dice.diceY] = dice.diceCur;
			
			// run action
			CCMoveBy *moveBy = [CCMoveBy actionWithDuration:0.3f position:point];
			CCSequence *seq = [CCSequence actions:moveBy,nil];
			[dice runAction:seq];
		}
	}
	
	[array release];
	
	return YES;
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint touchlocation = [touch locationInView:[touch view]];
	touchlocation = [[CCDirector sharedDirector] convertToGL:touchlocation];
	
	if (m_pDiceCurTouched != nil) 
	{
		if (m_pMoveShowRect.position.x != -100 && m_pMoveShowRect.position.y != -100) 
		{
			m_bCanTouched = NO; // set current state can't touched in layer.
			
			// judge can moved dice
			if ([self judgeCanMovedDice] == NO)
			{
				m_pDiceCurTouched = nil;
				m_nMoveDirection = -10;
				m_pMoveShowRect.position = ccp(-100,-100);
				return;
			}
			
			// change position for touched
			CCMoveTo *moveTo = [CCMoveTo actionWithDuration:0.3f position:m_pMoveShowRect.position];
			CCSequence *seq = [CCSequence actions:moveTo,[CCCallFunc actionWithTarget:self selector:@selector(updateTouchedDice:)],nil];
			[m_pDiceCurTouched runAction:seq];
		}
	}
	m_pMoveShowRect.position = ccp(-100,-100);
}

- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	m_pDiceCurTouched = nil;
	m_nMoveDirection = -10;
	m_pMoveShowRect.position = ccp(-100,-100);
}

@end
