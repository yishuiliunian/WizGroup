//
//  WGDetailListCell.h
//  WizGroup
//
//  Created by wiz on 12-10-22.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WGDetailListCell : UITableViewCell
@property (atomic, retain) NSString* documentGuid;
@property (atomic, retain) NSString* kbGuid;
@property (atomic, retain) NSString* accountUserId;
@end
