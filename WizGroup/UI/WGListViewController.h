//
//  WGListViewController.h
//  WizGroup
//
//  Created by wiz on 12-9-29.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <UIKit/UIKit.h> 

enum WGListType {
    WGListTypeRecent = 0,
    WGListTypeTag = 1,
    WGListTypeUnread = 2,
    WGListTypeNoTags = 3
    };

@interface WGListViewController : UITableViewController
@property (nonatomic, retain) NSString* kbGuid;
@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, assign) enum WGListType listType;
@property (nonatomic, retain) NSString* listKey;
@property (nonatomic, retain) WizGroup* kbGroup;
- (void) reloadAllData;
@end
