//
//  WGReadViewController.h
//  WizGroup
//
//  Created by wiz on 12-10-8.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WGReadListDelegate <NSObject>

- (WizDocument*) currentDocument;
- (WizDocument*) nextDocument;
- (WizDocument*) preDocument;

@end

@interface WGReadViewController : UIViewController
@property (assign, nonatomic) id<WGReadListDelegate> listDelegate;
@property (nonatomic, retain) NSString* kbguid;
@property (nonatomic, retain) NSString* accountUserId;
@end
