//
//  WGMainViewController.m
//  WizGroup
//
//  Created by wiz on 12-9-29.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WGMainViewController.h"
#import "GMGridView.h"
#import "WGGridViewCell.h"
#import "GMGridViewLayoutStrategies.h"
#import <QuartzCore/QuartzCore.h>
#import "WizAccountManager.h"

#import "PPRevealSideViewController.h"

#import "WGDetailViewController.h"
#import "WGListViewController.h"

#import "WizSyncCenter.h"
@interface WGMainViewController () <GMGridViewDataSource, GMGridViewActionDelegate>
{
    GMGridView* groupGridView;
    NSMutableArray* groupsArray;
}
@end

@implementation WGMainViewController

- (void) dealloc
{
    [groupGridView release];
    [groupsArray release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[WizNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadGroupView) name:WizNMDidUpdataGroupList object:nil];
    }
    return self;
}
- (void) loadView
{
    [super loadView];
    GMGridView *gmGridView = [[GMGridView alloc] initWithFrame:self.view.bounds];
    gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gmGridView.style = GMGridViewStylePush;
    gmGridView.itemSpacing = 5;
    gmGridView.minEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    gmGridView.centerGrid = YES;
    gmGridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutVertical];
    [self.view addSubview:gmGridView];
    groupGridView = gmGridView;
}


- (void) reloadGroupView
{
    WizAccountManager* accountManager = [WizAccountManager defaultManager];
    NSString* accountUserId = [accountManager activeAccountUserId];
    NSArray* groups = [accountManager groupsForAccount:accountUserId];
    [groupsArray removeAllObjects];
    [groupsArray addObjectsFromArray:groups];
    [groupGridView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    groupGridView.mainSuperView = self.navigationController.view;
    groupGridView.dataSource = self;
    groupGridView.actionDelegate = self;
    groupsArray = [[NSMutableArray alloc] init];
    [self reloadGroupView];
    
    //
    UIBarButtonItem* refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshGroupData)];
    self.navigationItem.rightBarButtonItem = refresh;
    [refresh release];
	// Do any additional setup after loading the view.
}

- (NSInteger) numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [groupsArray count];
}
- (CGSize) GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(140 , 140);
}

- (GMGridViewCell*) GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    WGGridViewCell *cell = (WGGridViewCell*)[gridView dequeueReusableCell];
    
    if (!cell)
    {
        cell = [[[WGGridViewCell alloc] initWithSize:size] autorelease];
    }
    
    WizGroup* group = [groupsArray objectAtIndex:index];
    
    cell.textLabel.text =  group.kbName;
    cell.imageView.image = [UIImage imageNamed:@"a.PNG"];
    [cell setBadgeCount:3];
    return cell;
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    groupsArray = nil;
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    WizGroup* group = [groupsArray objectAtIndex:position];
    NSString* activeAccountUserId = [[WizAccountManager defaultManager] activeAccountUserId];
    
    
    WGDetailViewController* detailCon = [[WGDetailViewController alloc] init];
    detailCon.kbGuid = group.kbguid;
    detailCon.accountUserId = activeAccountUserId;
    //
    WGListViewController* listCon = [[WGListViewController alloc] init];
    listCon.kbGuid = group.kbguid;
    listCon.accountUserId = activeAccountUserId;
    listCon.listType = WGListTypeRecent;
    //
       UINavigationController* centerNav = [[UINavigationController alloc] initWithRootViewController:listCon];
    
    PPRevealSideViewController* ppSideController = [[PPRevealSideViewController alloc] initWithRootViewController:centerNav];
    [ppSideController setDirectionsToShowBounce:PPRevealSideDirectionLeft];
    [ppSideController preloadViewController:detailCon forSide:PPRevealSideDirectionLeft];
    
    CATransition *tran = [CATransition animation];
    tran.duration = .4f;
    tran.type = kCATransitionPush;
    tran.subtype = kCATransitionFromTop; //Bottom for the opposite direction
    tran.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    tran.removedOnCompletion  = YES;
    [self.navigationController.view.layer addAnimation:tran forKey:@"TransitionDownUp"];
    [self.navigationController presentModalViewController:ppSideController animated:YES];
    
    [detailCon release];
    [listCon release];
    [ppSideController release];
    [centerNav release];
}

- (void) refreshGroupData
{
    WizSyncCenter* center = [WizSyncCenter defaultCenter];
    NSString* activeAccountUserId = [[WizAccountManager defaultManager] activeAccountUserId];
    for (WizGroup* each in groupsArray) {
        [center refreshGroupData:each.kbguid accountUserId:activeAccountUserId];
        break;
    }
}

@end
