//
//  GameDiceSprite.m
//  rDice
//
//  Created by o0402 on 11-7-12.
//  Copyright 2011 inblue. All rights reserved.
//

#import "GameDiceSprite.h"


@implementation GameDiceSprite

@synthesize diceCur = diceCur_;
@synthesize diceOld = diceOld_;
@synthesize diceX = diceX_;
@synthesize diceY = diceY_;
@synthesize diceOldX = diceOldX_;
@synthesize diceOldY = diceOldY_;

-(id) init
{
	if ((self = [super init])) 
	{
		self.diceOldX = self.diceOldY = self.diceX = self.diceY = self.diceCur = self.diceOld = INVALID_DICE;
	}
	return self;
}

-(void) dealloc
{
	self.diceOldX = self.diceOldY = self.diceX = self.diceY = self.diceCur = self.diceOld = INVALID_DICE;
	[super dealloc];
}

-(void) updateTexture
{
	
}

@end
