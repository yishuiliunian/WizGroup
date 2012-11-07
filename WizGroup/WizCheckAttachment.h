//
//  WizCheckAttachment.h
//  Wiz
//
//  Created by wiz on 12-3-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizCheckAttachment : UIViewController
{
    UIWebView* webView;
    NSURLRequest* req;
    NSString* attachmentGUID;
}
@property (nonatomic, retain) UIWebView* webView;
@property (nonatomic, retain) NSURLRequest* req;
@property (nonatomic, retain) NSString* attachmentGUID;
@end
