//
//  UINavigationBar+WizCustom.m
//  WizGroup
//
//  Created by wiz on 12-10-22.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "UINavigationBar+WizCustom.h"

@implementation UINavigationBar (WizCustom)
- (void) drawRect:(CGRect)rect
{
    UIImage* backImage = [UIImage imageNamed:@"a.PNG"];
    [backImage drawInRect:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
}
@end
