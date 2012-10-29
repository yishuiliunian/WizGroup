//
//  WGToolBar.m
//  WizGroup
//
//  Created by wiz on 12-10-29.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WGToolBar.h"

@implementation WGToolBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    UIImage* image = [UIImage imageNamed:@"toolbarBackgroud"];
    [image drawInRect:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
}


@end
