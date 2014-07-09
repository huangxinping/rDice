//
//  UniversalClass.m
//  YeTiDown Alpha0.1.0
//
//  Created by 温 晓佩 on 10-8-9.
//  Copyright 2010 nonoDreams Studio. All rights reserved.
//

#import "UniversalClass.h"
#import "SimpleAudioEngine.h"


@implementation UniversalClass

#pragma mark  保存数据到文本中
+(void)saveData:(NSString *)data WithFile:(NSString *)filename
{
	//文件路径
	NSString *appFile = [UniversalClass getFilePath:filename];
	//将数据写入文本
	NSData *writer = [[NSData alloc] initWithData:[data dataUsingEncoding:NSUTF8StringEncoding]];
	[writer writeToFile:appFile atomically:NO];
	[writer release];
}
//从文本中读取数据
+(NSString *)readDataWithFile:(NSString *)filename
{
	//文件路径
	NSString *appFile = [UniversalClass getFilePath:filename];
	//从文本中读取数据
	NSData *reader = [[NSData alloc] initWithContentsOfFile:appFile];
	NSString *result = [[NSString alloc] initWithData:[reader subdataWithRange:NSMakeRange(0, [reader length])] encoding:NSUTF8StringEncoding];
	[reader release];
	return result;
}
//获取文件路径
+(NSString *)getFilePath:(NSString *)filename
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:filename];
}

#pragma mark 播放点击声音
+(void)shortVoiceName:(NSString *)_name
{
	[[SimpleAudioEngine sharedEngine]playEffect:_name];
}

#pragma mark 播放背景音乐
+(void)PlayVoiceName:(NSString *)_name
{
	[[SimpleAudioEngine sharedEngine] playBackgroundMusic:_name loop:YES];
}

#pragma mark 暂停背景音
+(void)stopBgSound
{
	[[SimpleAudioEngine sharedEngine]stopBackgroundMusic];
}

@end
