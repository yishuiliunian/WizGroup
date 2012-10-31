//
//  WGListViewController.m
//  WizGroup
//
//  Created by wiz on 12-9-29.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WGListViewController.h"
#import "PPRevealSideViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WizDbManager.h"
#import "WGReadViewController.h"
#import "WGNavigationBar.h"

#import "WGDetailListCell.h"
#import "WGBarButtonItem.h"

@interface WGListViewController () <WGReadListDelegate, WGDetailCellDelegate>
{
    NSMutableArray* documentsArray;
}
@property (nonatomic, retain) NSIndexPath* lastIndexPath;
@end

@implementation WGListViewController
@synthesize kbGuid;
@synthesize accountUserId;
@synthesize listType;
@synthesize listKey;
@synthesize lastIndexPath;
- (void) dealloc
{
    [self removeObserver:self forKeyPath:@"listKey"];
    [listKey release];
    [lastIndexPath release];
    [documentsArray release];
    [kbGuid release];
    [accountUserId release];
    [super dealloc];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"listKey"]) {
        [self reloadAllData];
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self addObserver:self forKeyPath:@"listKey" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew  context:nil];
        documentsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) loadRecentsDocument
{
    id<WizMetaDataBaseDelegate> db = [[WizDbManager shareInstance] getMetaDataBaseForAccount:self.accountUserId kbGuid:self.kbGuid];
    [documentsArray addObjectsFromArray:[db recentDocuments]];
}

- (void) loadTagDocument
{
    id<WizMetaDataBaseDelegate> db = [[WizDbManager shareInstance] getMetaDataBaseForAccount:self.accountUserId kbGuid:self.kbGuid];
    [documentsArray addObjectsFromArray:[db documentsByTag:self.listKey]];
}

- (void) loadUnreadDocument
{
    id<WizMetaDataBaseDelegate> db = [[WizDbManager shareInstance] getMetaDataBaseForAccount:self.accountUserId kbGuid:self.kbGuid];
    [documentsArray addObjectsFromArray:[db unreadDocuments]];
}
- (void) reloadAllData
{
    [documentsArray removeAllObjects];
    switch (listType) {
        case WGListTypeRecent:
            [self loadRecentsDocument];
            break;
        case WGListTypeTag:
            [self loadTagDocument];
            break;
        case WGListTypeUnread:
            [self loadUnreadDocument];
            break;
        default:
            [self loadRecentsDocument];
            break;
    }
    [self.tableView reloadData];
}

- (void) backToHome
{
    CATransition *tran = [CATransition animation];
    
    tran.duration = .4f;
    
    tran.type = kCATransitionPush;
    
    tran.subtype = kCATransitionFromBottom; //Bottom for the opposite direction
    
    tran.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    tran.removedOnCompletion  = YES;
    
    [self.navigationController.view.layer addAnimation:tran forKey:@"TransitionDownUp"];
    [self.revealSideViewController dismissModalViewControllerAnimated:YES];
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadAllData];
    
    self.revealSideViewController.panInteractionsWhenClosed = PPRevealSideInteractionContentView | PPRevealSideInteractionNavigationBar;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void) showLeftController
{
    [self.revealSideViewController pushOldViewControllerOnDirection:PPRevealSideDirectionLeft animated:YES];
}
- (void) customizeNavBar {
    [self.navigationController setValue:[[[WGNavigationBar alloc] init] autorelease] forKeyPath:@"navigationBar"];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeNavBar];
    UIButton* cusButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 40, 90)];
    cusButton.backgroundColor = [UIColor redColor];
    [cusButton addTarget:self action:@selector(backToHome) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* backToHome = [[UIBarButtonItem alloc] initWithCustomView:cusButton];
    [cusButton release];
    self.navigationItem.rightBarButtonItem  = backToHome;
    [backToHome release];
    
    WGBarButtonItem* showLeftItem = [[WGBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"listIcon"] hightedImage:[UIImage imageNamed:@"listIcon"] target:self selector:@selector(showLeftController)];

    self.navigationItem.leftBarButtonItem = showLeftItem;
    [showLeftItem release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [documentsArray count];
}

- (WizDocument*) getCellNeedDisplayDocumentFor:(NSString *)docGuid
{
    for (WizDocument* each in documentsArray) {
        if ([each.strGuid isEqualToString:docGuid]) {
            return each;
        }
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListCell";
    WGDetailListCell *cell = (WGDetailListCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (nil == cell) {
        cell = [[[WGDetailListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    WizDocument* doc = [documentsArray objectAtIndex:indexPath.row];
    cell.documentGuid = doc.strGuid;
    cell.kbGuid = self.kbGuid;
    cell.accountUserId = self.accountUserId;
    cell.delegate = self;
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {

    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.lastIndexPath = indexPath;
    WGReadViewController* readController = [[WGReadViewController alloc] init];
    readController.kbguid = self.kbGuid;
    readController.accountUserId = self.accountUserId;
    readController.listDelegate = self;
    
    
    [self.navigationController pushViewController:readController animated:YES];
    self.revealSideViewController.panInteractionsWhenClosed = PPRevealSideInteractionNone;
    [readController release];
}
// read deleagte

- (WizDocument*) currentDocument
{
    if (self.lastIndexPath!= nil  && self.lastIndexPath.row < [documentsArray count]) {
        return [documentsArray objectAtIndex:self.lastIndexPath.row];
    }
    return nil;
}

- (BOOL) shouldCheckNextDocument
{
    if (self.lastIndexPath != nil) {
        if (self.lastIndexPath.row + 1 < [documentsArray count]) {
            return YES;
        }
    }
    return NO;
}

- (void) moveToNextDocument
{
    if ([self shouldCheckNextDocument]) {
        self.lastIndexPath = [NSIndexPath indexPathForRow:self.lastIndexPath.row+1 inSection:0];
    }
}

- (BOOL) shouldCheckPreDocument
{
    if (self.lastIndexPath != nil) {
        if (self.lastIndexPath.row - 1 >= 0) {
            return YES;
        }
    }
    return NO;
}

- (void) moveToPreDocument
{
    if ([self shouldCheckPreDocument]) {
        self.lastIndexPath = [NSIndexPath indexPathForRow:self.lastIndexPath.row -1 inSection:0];
    }
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setNeedsDisplay];
}
@end
