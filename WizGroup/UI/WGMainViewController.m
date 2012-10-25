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

#import "WGGlobalCache.h"

#import "UINavigationBar+WizCustom.h"

#import "WizDbManager.h"

@interface WGMainViewController () <GMGridViewDataSource, GMGridViewActionDelegate>
{
    GMGridView* groupGridView;
    NSMutableArray* groupsArray;
}
@property (atomic, assign) NSInteger numberOfSyncingGroups;
@end

@implementation WGMainViewController

- (void) dealloc
{
    [groupGridView release];
    [groupsArray release];
    [super dealloc];
}
- (void) startSync:(NSNotification*)nc
{
    self.numberOfSyncingGroups ++;
    if (self.numberOfSyncingGroups != 0) {
        [self showActivityIndicator];
    }
}
- (void) endSync:(NSNotification*)nc
{
    self.numberOfSyncingGroups --;
    if (self.numberOfSyncingGroups == 0) {
        [self showReloadButton];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[WizNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadGroupView) name:WizNMDidUpdataGroupList object:nil];
        
        WizNotificationCenter* center = [WizNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(startSync:) name:WizNMSyncGroupStart object:nil];
        [center addObserver:self selector:@selector(endSync:) name:WizNMSyncGroupEnd object:nil];
        [center addObserver:self selector:@selector(endSync:) name:WizNMSyncGroupError object:nil];
    }
    return self;
}
- (void) loadView
{
    [super loadView];
    UIImageView* backgroudView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gridBackgroud"]];
    backgroudView.frame = [UIScreen mainScreen].bounds;
    [self.view addSubview:backgroudView];
    [backgroudView release];
    //
    GMGridView *gmGridView = [[GMGridView alloc] initWithFrame:self.view.bounds];
    gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gmGridView.style = GMGridViewStylePush;
    gmGridView.itemSpacing = 10;
    gmGridView.minEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
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
- (void) drawBackgroud
{
    
}
- (void) settingApp
{
    
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
    //
    UIBarButtonItem* setItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(settingApp)];
	self.navigationItem.leftBarButtonItem = setItem;
    [setItem release];
    //
    UIImage* image = [UIImage imageNamed:@"navigationBackGroud"];

    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
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
    
    MULTIBACK(^(void){
        UIImage* image =  [[WGGlobalCache shareInstance] imageForGroupKbguid:group.kbguid];
        if (image == nil) {
            if ([[WGGlobalCache shareInstance] generateImageForKbguid:group.kbguid]) {
                image = [[WGGlobalCache shareInstance] imageForGroupKbguid:group.kbguid];
            }
        }
        MULTIMAIN(^(void){
            cell.imageView.image = image;
        });
    });
    
    cell.kbguid = group.kbguid;
    cell.accountUserId = group.accountUserId;
    [cell setBadgeCount];
    if ([[WizSyncCenter defaultCenter] isSyncingGrop:group.kbguid accountUserId:group.accountUserId]) {
        [cell.activityIndicator startAnimating];
    }
    else
    {
        [cell.activityIndicator stopAnimating];
    }
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
- (void)showReloadButton {
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                    target:self
                                    action:@selector(refreshGroupData)];
    self.navigationItem.rightBarButtonItem = refreshItem;
    [refreshItem release];
}

- (void)showActivityIndicator {
    UIActivityIndicatorView *activityIndicator =
    [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [activityIndicator startAnimating];
    UIBarButtonItem *activityItem =
    [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [activityIndicator release];
    self.navigationItem.rightBarButtonItem = activityItem;
    [activityItem release];
}
- (void) refreshGroupData
{
    WizSyncCenter* center = [WizSyncCenter defaultCenter];
    NSString* activeAccountUserId = [[WizAccountManager defaultManager] activeAccountUserId];
    for (WizGroup* each in groupsArray) {
        [center refreshGroupData:each.kbguid accountUserId:activeAccountUserId];
    }
}

@end
