//
//  WGNavigationViewController.m
//  WizGroup
//
//  Created by wiz on 12-10-31.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WGNavigationViewController.h"
#import "WGToolBar.h"
#import "WGNavigationBar.h"
@interface WGNavigationViewController ()
{
    WGToolBar* wgToolBar;
}
@end

@implementation WGNavigationViewController
- (void) dealloc
{
    [wgToolBar release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        wgToolBar = [[WGToolBar alloc] init];
    }
    return self;
}
- (void) setWgToolItems:(NSArray*)array
{
    
    if (array == nil) {
        [self setToolbarHidden:YES];
    }
    else
    {
        [self setToolbarHidden:NO];
    }
    [wgToolBar setItems:array];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    wgToolBar.frame = CGRectMake(0.0, 0.0, self.toolbar.frame.size.width, self.toolbar.frame.size.height);
    [self.toolbar addSubview:wgToolBar];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
