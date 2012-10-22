//
//  WGGridViewCell.m
//  WizGroup
//
//  Created by wiz on 12-10-18.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WGGridViewCell.h"
#import "UIBadgeView.h"
#import <QuartzCore/QuartzCore.h>

#define FONT_SIZE   16

@interface WGGridViewCell ()
{
    UIBadgeView* badgeView;
    CGSize _size;
}
@end

@implementation WGGridViewCell
@synthesize imageView = _imageView;
@synthesize textLabel = _textLabel;


//计算文本所占高度
//2个参数：宽度和文本内容
-(CGFloat)calculateTextHeight:(CGFloat)widthInput Content:(NSString *)strContent{
    CGSize constraint = CGSizeMake(widthInput, 20000.0f);
    CGSize size = [strContent sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    CGFloat height = MAX(size.height, 44.0f);
    return height;
}


- (void) dealloc

{
    [self removeObserver:self forKeyPath:@"textLabel.text" context:nil];
    [badgeView release];
    [_textLabel release];
    [_imageView release];
    [super dealloc];
}

- (id) initWithSize:(CGSize)size
{
    self = [self init];
    if (self) {
        
        _size = size;
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, size.width, size.height)];
        
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 60, size.width, 20)];
    
        _textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _textLabel.textAlignment = UITextAlignmentCenter;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.highlightedTextColor = [UIColor whiteColor];
        _textLabel.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
        _textLabel.numberOfLines = 0;
        
        
        
        [_imageView addSubview:_textLabel];
        
        badgeView = [[UIBadgeView alloc] initWithFrame:CGRectMake(size.width - 5, -15, 30, 30)];
        [_imageView addSubview:badgeView];
        badgeView.hidden = YES;
        
        self.contentView = _imageView;
        self.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
        self.deleteButtonOffset = CGPointMake(-15, -15);
        
        //
        CALayer* layer = _imageView.layer;
        layer.borderColor = [UIColor grayColor].CGColor;
        layer.borderWidth = 0.5f;
        layer.shadowColor = [UIColor grayColor].CGColor;
        layer.shadowOffset = CGSizeMake(2, 2);
        layer.shadowOpacity = 0.5;
        layer.shadowRadius = 2;
        layer.cornerRadius = 5;
        
        [self addObserver:self forKeyPath:@"textLabel.text" options:NSKeyValueObservingOptionNew context:nil];
        
    }
    return self;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"textLabel.text"]) {
        NSString* text = [change objectForKey:@"new"];
        CGFloat height = [self calculateTextHeight:_size.width Content:text];
        NSLog(@"content height is %f  viewwidth %f",height, _size.width);
        
//        _textLabel.frame = CGRectMake(0.0, 0.0, self.contentView.frame.size.width, height);
    }
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
