//
//  GameLoadDelegate.h
//  loadingScene
//
//  Created by o0402 on 11-7-8.
//  Copyright 2011 inblue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@protocol GameLoadDelegate <NSObject>
@optional 
-(void) willBeginLoading;               
-(void) doLoading:(NSNumber*)precent;	// must rewrite in delagate
-(void) willEndLoading;					
@end

typedef enum enLoadingStyle
{
	LADOING_LAYER_RESOURCE,
}LoadingStyle;

@interface GameLoadMgr : NSObject <GameLoadDelegate> 
{ 
    id <GameLoadDelegate>	delegate; 
	int						m_nPrecent;
	LoadingStyle			m_enStyle;
}

@property(nonatomic,retain) id <GameLoadDelegate> delegate;

- (id) initWithLoadingStyle:(LoadingStyle) style;
- (void) beginLoading;

@end