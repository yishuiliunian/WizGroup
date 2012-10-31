//
//  WGBarButtonItem.m
//  WizGroup
//
//  Created by wiz on 12-10-30.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WGBarButtonItem.h"

@implementation WGBarButtonItem
- (id) initWithImage:(UIImage*)image hightedImage:(UIImage*)hightImage target:(id)target selector:(SEL)selector
{
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, 30, 30);
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:hightImage forState:UIControlStateHighlighted];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    self = [super initWithCustomView:button];
    [button release];
    if (self) {
        
    }
    return self;
}
@end
