//
//  GameTargetSprite.h
//  rDice
//
//  Created by Huang Xinping on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameTargetSprite : CCSprite 
{
	NSInteger diceX_;			// dice H index in array
	NSInteger diceY_;			// dice V index in array
}

@property(nonatomic,assign) NSInteger diceX;	
@property(nonatomic,assign) NSInteger diceY;

@end
