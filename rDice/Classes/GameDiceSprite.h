//
//  GameDiceSprite.h
//  rDice
//
//  Created by o0402 on 11-7-12.
//  Copyright 2011 inblue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define INVALID_DICE -55

@interface GameDiceSprite : CCSprite 
{
	NSInteger diceOld_;			// init dice number
	NSInteger diceCur_;			// current dice number
	
	NSInteger diceOldX_;		
	NSInteger diceX_;			// dice H index in array
	NSInteger diceOldY_;	
	NSInteger diceY_;			// dice V index in array
}

@property(nonatomic,assign) NSInteger diceOld;	// once init will don't change
@property(nonatomic,assign) NSInteger diceCur;
@property(nonatomic,assign) NSInteger diceOldX;	// once init will don't change
@property(nonatomic,assign) NSInteger diceX;	
@property(nonatomic,assign) NSInteger diceOldY;	// once init will don't change
@property(nonatomic,assign) NSInteger diceY;	

-(void) updateTexture;

@end
