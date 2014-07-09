//
//  PropertyListHelper.h
//  Eirlift
//
//  Created by yiqing on 03/07/2008.
//  Copyright 2008 Mapflow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PropertyListHelper : NSObject {
}

- (BOOL) makePersistent: (id) plist path: (NSString *) path;
- (id) readPropertyListFrom: (NSString *) path;
- (id) readPropertyValueFrom: (NSString *) path key: (NSString *) key;

+ (NSMutableArray *) getArrayFromPlist: (NSString *) path;

@end