//
//  UniversalClass.h
//  YeTiDown Alpha0.1.0
//
//  Created by 温 晓佩 on 10-8-9.
//  Copyright 2010 nonoDreams Studio. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UniversalClass : NSObject 
{

}

+(void)saveData:(NSString *)data WithFile:(NSString *)filename;

+(NSString *)readDataWithFile:(NSString *)filename;

+(NSString *)getFilePath:(NSString *)filename;

+(void)shortVoiceName:(NSString *)_name;

+(void)PlayVoiceName:(NSString *)_name;

+(void)stopBgSound;

@end
