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
    WGListTypeTag = 1
    };

@interface WGListViewController : UITableViewController
@property (nonatomic, retain) NSString* kbGuid;
@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, assign) enum WGListType listType;
@property (nonatomic, retain) NSString* listKey;

- (void) reloadAllData;
@end
