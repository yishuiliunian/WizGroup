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

@interface WGReadViewController () <UIScrollViewDelegate>
{
    UILabel* titleLabel;
    UIWebView*  readWebView;
    UIScrollView* backgroudScrollView;
    
    //
    UIBarButtonItem* checkNextButtonItem;
    UIBarButtonItem* checkPreButtonItem;
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
        //
        titleLabel = [[UILabel alloc] init];
        backgroudScrollView = [[UIScrollView alloc] init];
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

    CGSize contentSize = [self contentViewSize];
    float titleLabelHeight = 80;
    
    readWebView.frame = CGRectMake(0.0, titleLabelHeight +1, contentSize.width, contentSize.height);
    readWebView.scrollView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    titleLabel.frame = CGRectMake(0.0, 0.0, contentSize.width, titleLabelHeight);
    [backgroudScrollView addSubview:readWebView];
    [backgroudScrollView addSubview:titleLabel];
    backgroudScrollView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    backgroudScrollView.frame= CGRectMake(0.0, 0.0, contentSize.width, contentSize.height-10);
    backgroudScrollView.contentSize= CGSizeMake(contentSize.width, contentSize.height + titleLabelHeight-10);
    [self.view addSubview:backgroudScrollView];
    
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
    
    checkNextButtonItem = nextItem;
    checkPreButtonItem = preItem;
    
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

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:readWebView.scrollView]) {
        if (scrollView.contentOffset.y < 0) {
            [backgroudScrollView scrollRectToVisible:CGRectMake(0.0, 0.0, 60, 60) animated:YES];
        }
    }
}


@end
