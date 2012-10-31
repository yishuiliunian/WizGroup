//
//  WGNavigationBar.m
//  WizGroup
//
//  Created by wiz on 12-10-30.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WGNavigationBar.h"

@implementation WGNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    self.tintColor = [UIColor whiteColor];
    UIImage* image = [UIImage imageNamed:@"navigationBackgroup1"];
    [image drawInRect:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
}

@end
