//
//  WGTreeNode.h
//  WizGroup
//
//  Created by wiz on 12-10-25.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WGTreeNode : NSObject
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* keyString;
@property (nonatomic, retain) NSString* parentKeyString;
@property (nonatomic, assign) BOOL isExpanded;
@end
