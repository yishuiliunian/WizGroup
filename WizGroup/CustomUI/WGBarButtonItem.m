//
//  WGBarButtonItem.m
//  WizGroup
//
//  Created by wiz on 12-10-30.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WGBarButtonItem.h"


@implementation WGBarButtonItem


+ (UIBarButtonItem*) barButtonItemWithImage:(UIImage*)image hightedImage:(UIImage*)hightImage target:(id)target selector:(SEL)selector
{
    
    UIButton* customButtom = [UIButton buttonWithType:UIButtonTypeCustom];
    customButtom.frame = CGRectMake(0.0, 0.0, 30, 30);
    [customButtom setImage:image forState:UIControlStateNormal];
    [customButtom setImage:hightImage forState:UIControlStateHighlighted];
    [customButtom addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:customButtom];
    return [item autorelease];
}

@end
