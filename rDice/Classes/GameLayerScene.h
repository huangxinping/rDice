//
//  HelloWorldLayer.h
//  rDice
//
//  Created by o0402 on 11-7-11.
//  Copyright inblue 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "GameLoadDelegate.h"

// every child's index
#define BACKGROUND			 		0
#define LOGO 				 		1
#define SOUNDCONTROL 		 		2
#define PLAYGAME 			 		3
#define CREDITS 			 		4
#define GAMEINGNEWS			 		5
#define PLAYMOREGAMES		 		6
#define MIN_DICE_INDEX		 		70

@interface GameLayerScene : CCLayer<GameLoadDelegate>
{
@private	
	GameLoadMgr *m_pGameLoadMgr;
	CGPoint ptBackgroundDice;
}

+(id) scene;

@end
