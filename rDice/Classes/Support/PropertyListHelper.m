//
//  PropertyListHelper.m
//  Eirlift
//
//  Created by yiqing on 03/07/2008.
//  Copyright 2008 Mapflow. All rights reserved.
//

#import "PropertyListHelper.h"

@implementation PropertyListHelper

- (BOOL) makePersistent: (id) plist path: (NSString *) path {
	// serialization
	NSData *plistData = [NSPropertyListSerialization dataFromPropertyList: plist format: NSPropertyListBinaryFormat_v1_0 errorDescription: nil];
	
	if (plistData) {
		// persistent
		[plistData writeToFile: path atomically: YES];
		return YES;
	}
	else {
		return NO;
	}
}

- (id) readPropertyListFrom: (NSString *) path {
	NSData *plistData = [NSData dataWithContentsOfFile: path];
	return [NSPropertyListSerialization propertyListFromData: plistData 
										mutabilityOption: NSPropertyListImmutable 
										format: nil
										errorDescription: nil];
}

- (id) readPropertyValueFrom: (NSString *) path key: (NSString *) key {
	NSData *plistData = [NSData dataWithContentsOfFile: path];
	NSDictionary *plist = [NSPropertyListSerialization propertyListFromData: plistData 
													   mutabilityOption: NSPropertyListImmutable 
													   format: nil
													   errorDescription: nil];
	NSEnumerator *keyEnum = [plist keyEnumerator];
	NSString *plistKey;
	while ((plistKey = [keyEnum nextObject]) != nil) {
		if ([plistKey isEqualToString: key]) {
			return [plist objectForKey: plistKey];
		}
	}
	
	return nil;
}

+ (NSMutableArray *) getArrayFromPlist: (NSString *) path {
	NSString *errorDesc = nil;
	
	NSPropertyListFormat format;
	
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:path ofType:@"plist"];
	
	NSData *data = [[NSFileManager defaultManager] contentsAtPath:plistPath];
	
	NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
										  
										  propertyListFromData:data
										  
										  mutabilityOption:NSPropertyListImmutable
										  
										  format:&format errorDescription:&errorDesc];
	
	if (!temp) {
		NSLog(@"%@",errorDesc);
		[errorDesc release];
	}
	
	NSMutableArray *mushroomArray = [[NSMutableArray alloc] init];
	for(id key in temp){
		[mushroomArray addObject:[NSDictionary dictionaryWithObjectsAndKeys: key, @"x", [temp objectForKey:key], @"y", nil]];
	}
	
	NSLog(@"%@",mushroomArray);
	
	return [mushroomArray autorelease];
}

@end