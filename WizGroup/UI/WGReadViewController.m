//
//  WGReadViewController.m
//  WizGroup
//
//  Created by wiz on 12-10-8.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WGReadViewController.h"
#import "WizFileManager.h"
#import "WizAccountManager.h"
#import "WizSyncCenter.h"
#import "WizNotificationCenter.h"
#import "WizDbManager.h"

@interface WGReadViewController ()
@property (nonatomic, retain)   UIWebView* detailWebView;
@end

@implementation WGReadViewController
@synthesize detailWebView;
@synthesize listDelegate;
@synthesize accountUserId;
@synthesize kbguid;
- (void) dealloc
{
    [[WizNotificationCenter defaultCenter] removeObserver:self];
    listDelegate = nil;
    [detailWebView release];
    [accountUserId release];
    [kbguid release];
    [super dealloc];
}

- (void) didDownloadDocument:(NSNotification*)nc
{
    NSString* guid = [WizNotificationCenter getDocumentGuidFromNc:nc];
    if (nil != guid) {
        WizDocument* doc = [self.listDelegate currentDocument];
        if ([doc.strGuid isEqualToString:guid]) {
            [self loadDocument:doc];
        }
      
    }
}

- (id) init
{
    self = [super init];
    if (self) {
        [[WizNotificationCenter defaultCenter] addObserver:self selector:@selector(didDownloadDocument:) name:WizNMDidDownloadDocument object:nil];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void) downloadDocument:(WizDocument*)doc
{
    [[WizSyncCenter defaultCenter] downloadDocument:doc kbguid:self.kbguid accountUserId:self.accountUserId];
}

- (void) checkCurrentDocument
{
    WizDocument* currentDoc = [self.listDelegate currentDocument];
    if (currentDoc) {
        if (currentDoc.bServerChanged == NO) {
            [self loadDocument:currentDoc];
        }
        else
        {
            [self downloadDocument:currentDoc];
        }
    }
}
- (void) checkNextDocument
{
    if ([self.listDelegate shouldCheckNextDocument]) {
        [self.listDelegate moveToNextDocument];
        [self checkCurrentDocument];
    }
}
- (void) checkPreDocument
{
    if ([self.listDelegate shouldCheckPreDocument]) {
        [self.listDelegate moveToPreDocument];
        [self checkCurrentDocument];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    self.detailWebView = webView;
    [self.view addSubview:webView];
    [webView release];
    [self checkCurrentDocument];
    
//    NSArray* controls = @[@"N",@"P"];
//    UISegmentedControl* moveControl  = [[ UISegmentedControl alloc] initWithItems:controls];
//    UIBarButtonItem* moveItem = [[UIBarButtonItem alloc] initWithCustomView:moveControl];
//    self.navigationItem.rightBarButtonItem = moveItem;
//    [moveControl release ];
//    [moveItem release];
	// Do any additional setup after loading the view.
#warning  need fix to ios4
    UIBarButtonItem* nextItem = [[UIBarButtonItem alloc] initWithTitle:@"N" style:UIBarButtonItemStyleBordered target:self action:@selector(checkNextDocument)];
    UIBarButtonItem* preItem = [[UIBarButtonItem alloc] initWithTitle:@"P" style:UIBarButtonItemStyleBordered target:self action:@selector(checkPreDocument)];
    self.navigationItem.rightBarButtonItems = @[preItem,nextItem];
    [nextItem release];
    [preItem release];
}

- (void) downloadCurrentDocument
{
    WizSyncCenter* center = [WizSyncCenter defaultCenter];
    WizDocument* doc = [self.listDelegate currentDocument];
    
    [center downloadDocument:doc kbguid:self.kbguid accountUserId:self.accountUserId];
}

- (void) loadDocument:(WizDocument*)doc
{

    if (doc.bServerChanged == 0) {
        NSString* indexPath = [[WizFileManager shareManager] getDocumentFilePath:DocumentFileIndexName documentGUID:doc.strGuid accountUserId:self.accountUserId];
        if ([[WizFileManager shareManager] fileExistsAtPath:indexPath]) {
            NSURL* url = [NSURL fileURLWithPath:indexPath];
            NSURLRequest* request = [NSURLRequest requestWithURL:url];
            [self.detailWebView loadRequest:request];
            id<WizMetaDataBaseDelegate> db = [[WizDbManager shareInstance] getMetaDataBaseForAccount:self.accountUserId kbGuid:self.kbguid];
            [db updateDocumentReadCount:doc.strGuid];
        }
    }
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self downloadCurrentDocument];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
