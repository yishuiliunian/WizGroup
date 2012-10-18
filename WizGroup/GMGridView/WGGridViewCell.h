//
//  WGGridViewCell.h
//  WizGroup
//
//  Created by wiz on 12-10-18.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "GMGridViewCell.h"

@interface WGGridViewCell : GMGridViewCell
@property (nonatomic, retain) UIImageView* imageView;
@property (nonatomic, retain) UILabel*      textLabel;
- (id) initWithSize:(CGSize)size;
- (void) setBadgeCount:(NSInteger)count;
@end
