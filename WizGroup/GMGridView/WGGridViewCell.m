//
//  WGGridViewCell.m
//  WizGroup
//
//  Created by wiz on 12-10-18.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WGGridViewCell.h"
#import "JSBadgeView.h"
#import <QuartzCore/QuartzCore.h>
#import "WizNotificationCenter.h"
#import "WizSyncCenter.h"
#import "WizDbManager.h"
#import "WGGlobalCache.h"

#define FONT_SIZE   16

@interface WGGridViewCell () <WizUnreadCountDelegate, WGIMageCacheObserver>
{
    JSBadgeView* badgeView;
    CGSize _size;
    UIImageView* coverView;
    UIActivityIndicatorView* activityIndicatorView;
    //
    NSInteger countItem;
}
@end

@implementation WGGridViewCell
@synthesize imageView = _imageView;
@synthesize textLabel = _textLabel;
@synthesize kbguid;
@synthesize accountUserId;
@synthesize activityIndicator = activityIndicatorView;
//计算文本所占高度
//2个参数：宽度和文本内容
-(CGFloat)calculateTextHeight:(CGFloat)widthInput Content:(NSString *)strContent{
    
    @synchronized(self)
    {
        CGSize constraint = CGSizeMake(widthInput, 20000.0f);
        CGSize size = [strContent sizeWithFont:[UIFont boldSystemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeCharacterWrap];
        CGFloat height = size.height;
        return height;
    }
}


- (void) dealloc

{
    [[WizNotificationCenter defaultCenter] removeObserver:self];
//    [self removeObserver:self forKeyPath:@"textLabel.text" context:nil];
    [coverView release];
    [badgeView release];
    [_textLabel release];
    [_imageView release];
    [activityIndicatorView release];
    [kbguid release];
    [accountUserId release];
    [super dealloc];
}

- (id) initWithSize:(CGSize)size
{
    self = [self init];
    if (self) {
        
        static NSInteger _count = 0;
        countItem = _count++;
        //
        _size = size;
        
        CGRect imageRect = CGRectMake(0.0, 0.0, size.width, size.height);
        _imageView = [[UIImageView alloc] initWithFrame:imageRect];
        
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 60, size.width, 20)];
    
        _textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _textLabel.textAlignment = UITextAlignmentCenter;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.highlightedTextColor = [UIColor lightGrayColor];
        _textLabel.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
        _textLabel.numberOfLines = 0;
        _textLabel.frame = CGRectMake(0.0, _imageView.frame.size.height/2 - 20, size.width, 20);
//        _textLabel.shadowColor = [UIColor lightGrayColor];
//        _textLabel.shadowOffset = CGSizeMake(0.5, 0.5);
        
        
        [_imageView addSubview:_textLabel];
        
        badgeView = [[JSBadgeView alloc] initWithParentView:_imageView alignment:JSBadgeViewAlignmentTopRight];
        badgeView.hidden = YES;
        
        //
        coverView = [[UIImageView alloc] initWithFrame:imageRect];
        coverView.image = [UIImage imageNamed:@"menban"];
        [_imageView addSubview:coverView];
        //
        
        self.contentView = _imageView;
        self.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
        self.deleteButtonOffset = CGPointMake(-15, -15);
        
        //
//        CALayer* layer = _imageView.layer;
//
//        layer.shadowColor = [UIColor grayColor].CGColor;
//        layer.shadowOffset = CGSizeMake(2, 2);
//        layer.shadowOpacity = 0.5;
//        layer.shadowRadius = 2;
//        layer.cornerRadius = 5;
        [_imageView bringSubviewToFront:_textLabel];
//        [self addObserver:self forKeyPath:@"textLabel.text" options:NSKeyValueObservingOptionNew context:nil];
        //
        float activityViewHeight = 40;
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((size.width - activityViewHeight)/2, (size.height - activityViewHeight)/2, activityViewHeight, activityViewHeight)];
        [_imageView addSubview:activityIndicatorView];
        [_imageView bringSubviewToFront:activityIndicatorView];
        //
        WizNotificationCenter* center = [WizNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(startSync:) name:WizNMSyncGroupStart object:nil];
        [center addObserver:self selector:@selector(endSync:) name:WizNMSyncGroupEnd object:nil];
        [center addObserver:self selector:@selector(endSync:) name:WizNMSyncGroupError object:nil];
    }
    return self;
}
- (void) startSync:(NSNotification*)nc
{
    NSString* guid = [WizNotificationCenter getGuidFromNc:nc];
    if ([guid isEqualToString:self.kbguid]) {
        MULTIMAIN(^(void)
          {
              [activityIndicatorView startAnimating];
          });
    }
}
- (void) endSync:(NSNotification*)nc
{
    NSString* guid = [WizNotificationCenter getGuidFromNc:nc];
    if ([guid isEqualToString:self.kbguid]) {
        MULTIMAIN(^(void)
      {
            [activityIndicatorView stopAnimating];
      });
    }
    [self setBadgeCount];
}

//- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    if ([keyPath isEqualToString:@"textLabel.text"]) {
//        MULTIBACK(^(void)
//          {
//            CGFloat height = 0;
//            @synchronized(self)
//            {
//                  NSString* text = [change objectForKey:@"new"];
//                  height = [self calculateTextHeight:_size.width Content:text];
//            }
//            MULTIMAIN(^(void)
//            {
//                 _textLabel.frame = CGRectMake(0.0, self.contentView.frame.size.height - height - 8, self.contentView.frame.size.width, height);
//            });
//          });
//    }
//}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void) didGetUnreadCountForKbguid:(NSString*)guid  unreadCount:(int64_t)count
{
    if (![guid isEqualToString:self.kbguid]) {
        return;
    }
    if (count <= 0) {
        badgeView.hidden = YES;
    }
    else
    {
        badgeView.hidden = NO;
        if (count > 99) {
            badgeView.badgeText = [NSString stringWithFormat:@"99+"];
        }
        else
        {
            badgeView.badgeText = [NSString stringWithFormat:@"%lld",count];
        }
    }
}

- (void) didGetImage:(UIImage *)image forKbguid:(NSString *)guid
{
    if (![guid isEqualToString:self.kbguid]) {
        return;
    }
    _imageView.image = image;
}

- (void) setBadgeCount
{
    [WGGlobalCache getUnreadCountByKbguid:self.kbguid accountUserId:self.accountUserId observer:self];
    [[WGGlobalCache shareInstance] getAbstractImageForKbguid:self.kbguid accountUserId:self.accountUserId observer:self];
}

@end
