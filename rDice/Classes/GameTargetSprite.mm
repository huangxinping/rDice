//
//  GameTargetSprite.m
//  rDice
//
//  Created by Huang Xinping on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameTargetSprite.h"

#define INVALID_TARGET -55

@implementation GameTargetSprite

@synthesize diceX = diceX_;
@synthesize diceY = diceY_;

-(id) init
{
	if ((self = [super init])) 
	{
		self.diceX = self.diceY = INVALID_TARGET;
	}
	return self;
}

-(void) dealloc
{
	self.diceX = self.diceY = INVALID_TARGET;
	[super dealloc];
}

@end
