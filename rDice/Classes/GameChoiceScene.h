//
//  GameChoiceScene.h
//  rDice
//
//  Created by o0402 on 11-7-11.
//  Copyright 2011 inblue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameLoadDelegate.h"

@interface GameChoiceScene : CCLayer<GameLoadDelegate> 
{
@private	
	GameLoadMgr *m_pGameLoadMgr;
}

+(id) scene;

@end
