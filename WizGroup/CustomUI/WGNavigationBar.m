//
//  WGNavigationBar.m
//  WizGroup
//
//  Created by wiz on 12-10-30.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WGNavigationBar.h"


@implementation WGNavigationBar
@synthesize titleLabel;

- (void) dealloc
{
    [titleLabel release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:17];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    UIImage* image = [UIImage imageNamed:@"navigationBackgroup1"];
    self.titleLabel.frame = CGRectMake(0.0, 0.0, self.frame.size.width, 40);
    [image drawInRect:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
}

@end
