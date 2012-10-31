//
//  WGBarButtonItem.h
//  WizGroup
//
//  Created by wiz on 12-10-30.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WGBarButtonItem : UIBarButtonItem
+ (UIBarButtonItem*) barButtonItemWithImage:(UIImage*)image hightedImage:(UIImage*)hightImage target:(id)target selector:(SEL)selector;
@end
