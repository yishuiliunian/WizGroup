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

@interface WGListViewController () <WGReadListDelegate>
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem* backHome = [[UIBarButtonItem alloc] initWithTitle:@"home" style:UIBarButtonItemStyleBordered target:self action:@selector(backToHome)];
    self.navigationItem.rightBarButtonItem = backHome;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (nil == cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    WizDocument* doc = [documentsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = doc.strTitle;
    return cell;
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


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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

- (WizDocument*) currentDocument
{
    if (self.lastIndexPath!= nil  && self.lastIndexPath.row < [documentsArray count]) {
        return [documentsArray objectAtIndex:self.lastIndexPath.row];
    }
    return nil;
}

@end
