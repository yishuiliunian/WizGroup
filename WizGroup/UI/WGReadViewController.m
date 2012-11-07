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
#import "WGToolBar.h"
#import "WGBarButtonItem.h"
#import "WGNavigationViewController.h"
//
#import "MBProgressHUD.h"
#import "WizCheckAttachments.h"

#import "DocumentInfoViewController.h"

@interface WGReadViewController () <UIScrollViewDelegate, UIWebViewDelegate>
{
    UILabel* titleLabel;
    UIWebView*  readWebView;
    UIScrollView* backgroudScrollView;
    
    //
    UIBarButtonItem* checkNextButtonItem;
    UIBarButtonItem* checkPreButtonItem;
    //
}

@end

@implementation WGReadViewController

@synthesize listDelegate;
@synthesize accountUserId;
@synthesize kbguid;
- (void) dealloc
{
    [[WizNotificationCenter defaultCenter] removeObserver:self];
    listDelegate = nil;
    [accountUserId release];
    [kbguid release];
    //
    [titleLabel release];
    [readWebView release];
    [backgroudScrollView release];
    //
    [super dealloc];
}

- (void) setCheckNextDocumentButtonEnable
{
    if ([self.listDelegate shouldCheckNextDocument]) {
        [checkNextButtonItem setEnabled:YES];
    }
    else
    {
        [checkNextButtonItem setEnabled:NO];
    }
}

- (void) setCheckPreDocumentButtonEnable
{
    if ([self.listDelegate shouldCheckPreDocument]) {
        [checkPreButtonItem setEnabled:YES];
    }
    else
    {
        [checkPreButtonItem setEnabled:NO];
    }
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
        readWebView = [[UIWebView alloc] init];
        readWebView.scrollView.delegate = self;
        readWebView.delegate = self;
        //
        titleLabel = [[UILabel alloc] init];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        
        backgroudScrollView = [[UIScrollView alloc] init];
        //
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
- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void) webViewDidStartLoad:(UIWebView *)webView
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}
- (void) downloadDocument:(WizDocument*)doc
{
    [[WizSyncCenter defaultCenter] downloadDocument:doc kbguid:self.kbguid accountUserId:self.accountUserId];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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
     [self setCheckNextDocumentButtonEnable];
     [self setCheckPreDocumentButtonEnable];
}
- (void) checkNextDocument
{
    if ([self.listDelegate shouldCheckNextDocument]) {
        [self.listDelegate moveToNextDocument];
        [self checkCurrentDocument];
    }
   
}
//
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
    [self customToolBar];

    CGSize contentSize = [self contentViewSize];
    float titleLabelHeight = 40;
    
    UIView* lineBreak = [[UIView alloc] initWithFrame:CGRectMake(0.0, titleLabelHeight-1, self.view.frame.size.width, 1)];
    lineBreak.backgroundColor = WGDetailCellBackgroudColor;

    readWebView.frame = CGRectMake(0.0, titleLabelHeight, contentSize.width, contentSize.height);
    readWebView.scrollView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    titleLabel.frame = CGRectMake(0.0, 0.0, contentSize.width, titleLabelHeight);
    [titleLabel addSubview:lineBreak];
    [lineBreak release];
    
    [backgroudScrollView addSubview:readWebView];
    [backgroudScrollView addSubview:titleLabel];
    backgroudScrollView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    backgroudScrollView.frame= CGRectMake(0.0, 0.0, contentSize.width, contentSize.height);
    backgroudScrollView.contentSize= CGSizeMake(contentSize.width, contentSize.height + titleLabelHeight);
    [self.view addSubview:backgroudScrollView];
    [self checkCurrentDocument];
}

- (void) downloadCurrentDocument
{
    WizSyncCenter* center = [WizSyncCenter defaultCenter];
    WizDocument* doc = [self.listDelegate currentDocument];
    
    [center downloadDocument:doc kbguid:self.kbguid accountUserId:self.accountUserId];
}
- (void) shareCurrentDoc
{
    [WizGlobals reportWarningWithString:@"您将分享此文档"];
}

- (void) feedbackCurrentDoc
{
    [WizGlobals reportWarningWithString:@"评论此文档"];
}

- (void) checkAttachment
{
    WizCheckAttachments* check = [[WizCheckAttachments alloc] init];
    check.doc = [self.listDelegate currentDocument];
    check.kbguid = self.kbguid;
    check.accountUserId = self.accountUserId;
    WGNavigationViewController* nav = [[WGNavigationViewController alloc] initWithRootViewController:check];
    [self.navigationController presentModalViewController:nav animated:YES];
    [nav release];
    [check release];
}
- (void) checkInfo
{
    DocumentInfoViewController* infoCheck = [[DocumentInfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
    infoCheck.doc = [self.listDelegate currentDocument];
    [self.navigationController pushViewController:infoCheck animated:YES];
    [infoCheck release];
}

- (void) customToolBar
{
    WGNavigationViewController* nav = (WGNavigationViewController*)self.navigationController;
    
    UIBarButtonItem* flexItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    
    UIBarButtonItem* backToList = [WGBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"read_back"] hightedImage:[UIImage imageNamed:@""] target:self selector:@selector(backToList)];
    UIBarButtonItem* nextItem = [WGBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"read_next"] hightedImage:[UIImage imageNamed:@""] target:self selector:@selector(checkNextDocument)];
    checkNextButtonItem = nextItem;
    UIBarButtonItem* preItem = [WGBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"read_previous"] hightedImage:[UIImage imageNamed:@""] target:self selector:@selector(checkPreDocument)];
    checkPreButtonItem = preItem;
    
    UIBarButtonItem* attachmentItem = [WGBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"read_attachment"] hightedImage:nil target:self selector:@selector(checkAttachment)];
    UIBarButtonItem* infoItem = [WGBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"read_info"] hightedImage:nil target:self selector:@selector(checkInfo)];
    
    [nav setWgToolItems:@[backToList,flexItem,infoItem,attachmentItem,preItem,nextItem]];
}

- (void) backToList
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) loadDocument:(WizDocument*)doc
{
    if (doc.bServerChanged == 0) {
        NSString* indexPath = [[WizFileManager shareManager] getDocumentFilePath:DocumentFileIndexName documentGUID:doc.strGuid accountUserId:self.accountUserId];
        if ([[WizFileManager shareManager] fileExistsAtPath:indexPath]) {
            titleLabel.text = doc.strTitle;
            NSURL* url = [NSURL fileURLWithPath:indexPath];
            NSURLRequest* request = [NSURLRequest requestWithURL:url];
            [readWebView loadRequest:request];
            id<WizMetaDataBaseDelegate> db = [[WizDbManager shareInstance] getMetaDataBaseForAccount:self.accountUserId kbGuid:self.kbguid];
            [db updateDocumentReadCount:doc.strGuid];
        }
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self customToolBar];
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

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

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:readWebView.scrollView]) {
        if (scrollView.contentOffset.y < 0) {
            [backgroudScrollView scrollRectToVisible:CGRectMake(0.0, 0.0, 60, 60) animated:YES];
        }
    }
}


@end
