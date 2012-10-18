//
//  WGGridViewCell.m
//  WizGroup
//
//  Created by wiz on 12-10-18.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WGGridViewCell.h"
#import "UIBadgeView.h"
@interface WGGridViewCell ()
{
    UIBadgeView* badgeView;
}
@end

@implementation WGGridViewCell
@synthesize imageView = _imageView;
@synthesize textLabel = _textLabel;
- (void) dealloc

{
    [badgeView release];
    [_textLabel release];
    [_imageView release];
    [super dealloc];
}

- (id) initWithSize:(CGSize)size
{
    self = [self init];
    if (self) {
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, size.width, size.height)];
        
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, size.width, size.height)];
    
        _textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _textLabel.textAlignment = UITextAlignmentCenter;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.highlightedTextColor = [UIColor whiteColor];
        _textLabel.font = [UIFont boldSystemFontOfSize:20];
        

        [_imageView addSubview:_textLabel];
        
        badgeView = [[UIBadgeView alloc] initWithFrame:CGRectMake(-15, -15, 30, 30)];
        [_imageView addSubview:badgeView];
        badgeView.hidden = YES;
        
        self.contentView = _imageView;
        self.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
        self.deleteButtonOffset = CGPointMake(-15, -15);
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setBadgeCount:(NSInteger)count
{
    if (count <= 0) {
        badgeView.hidden = YES;
    }
    else
    {
        badgeView.hidden = NO;
        badgeView.badgeString = [NSString stringWithFormat:@"%d",count];
    }
}

@end
