//
//  GamePlayScene.h
//  rDice
//
//  Created by o0402 on 11-7-11.
//  Copyright 2011 inblue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameLoadDelegate.h"
#import "GameDiceSprite.h"
#import "GameTargetSprite.h"

#define INVALID_STAGE		-55
#define MAX_ARRAY_X			6   
#define MAX_ARRAY_Y			9		
#define MOVE_RECT_INDEX		200

#define BLOCK_EMPTY_DICE    99

#define MOVE_LEFT	1
#define MOVE_RIGHT	2
#define MOVE_TOP	3
#define MOVE_BOTTOM 4

@interface GamePlayScene : CCLayer<GameLoadDelegate>  
{
@private	
	GameLoadMgr			*m_pGameLoadMgr;
	NSInteger			levelCurrentPlay_;
	NSMutableArray		*m_pMoveDiceArray;
	NSMutableArray		*m_pTargerArray;
	GameDiceSprite		*m_pDiceCurTouched;
	int					m_nDiceMapArray[MAX_ARRAY_X][MAX_ARRAY_Y];
	CCSprite			*m_pMoveShowRect;
	int					m_nMoveDirection;
	BOOL				m_bCanTouched;
}

+(id) scene:(int)stage;
@property (nonatomic, assign) NSInteger levelCurrentPlay;

@end
