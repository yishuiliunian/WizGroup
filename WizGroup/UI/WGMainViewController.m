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
#import "WGLoginViewController.h"
#import "WGSettingViewController.h"

#import "PPRevealSideViewController.h"

#import "WGDetailViewController.h"
#import "WGListViewController.h"

#import "WizSyncCenter.h"

#import "WGGlobalCache.h"

#import "UINavigationBar+WizCustom.h"

#import "WizDbManager.h"
//
#import "WGToolBar.h"

@interface WGMainViewController () <GMGridViewDataSource, GMGridViewActionDelegate, EGORefreshTableHeaderDelegate, UIScrollViewDelegate>
{
    GMGridView* groupGridView;
    NSMutableArray* groupsArray;
    //
    UIView*     titleView;
    BOOL    isRefreshing;
}
@property (atomic, assign) NSInteger numberOfSyncingGroups;

@end

@implementation WGMainViewController

- (void) dealloc
{
    [[WizNotificationCenter defaultCenter] removeObserver:self];
    [titleView release];
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
        [self doneLoadingTableViewData];
    }
}

- (void) doneLoadingTableViewData
{
    isRefreshing = NO;
    [groupGridView.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:groupGridView];
}
- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [groupGridView.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [groupGridView.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}
- (void) egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    isRefreshing = YES;
    NSString* accountUserId = [[WizAccountManager defaultManager] activeAccountUserId];
    [[WizSyncCenter defaultCenter] refreshGroupsListFor:accountUserId];
}

- (BOOL) egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return isRefreshing;
}

- (NSDate*) egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[WizNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAllGroups) name:WizNMDidUpdataGroupList object:nil];
        [[WizNotificationCenter defaultCenter] addObserver:self selector:@selector(clearGroupView) name:WizNMWillUpdateGroupList object:nil];
        
        WizNotificationCenter* center = [WizNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(startSync:) name:WizNMSyncGroupStart object:nil];
        [center addObserver:self selector:@selector(endSync:) name:WizNMSyncGroupEnd object:nil];
        [center addObserver:self selector:@selector(endSync:) name:WizNMSyncGroupError object:nil];
    }
    return self;
}
- (void) testMulti
{
    __block int testInt = 0;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"m start %d",testInt++);
        NSLog(@"m end");
        for (int i = 0; i< 10000; i++) {
            ;
        }
    });
    NSLog(@"end %d",testInt);
}
- (void) loadView
{
    [super loadView];
    //
    UIImageView* backgroudView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gridBackgroud"]];
    backgroudView.frame = [UIScreen mainScreen].bounds;
//    [self.view addSubview:backgroudView];
    [backgroudView release];
    //
    GMGridView *gmGridView = [[GMGridView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - 44)];
    gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gmGridView.style = GMGridViewStylePush;
    gmGridView.itemSpacing = 5;
    gmGridView.minEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    gmGridView.centerGrid = NO;
    gmGridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutVertical];
    gmGridView.refreshHeaderView.delegate = self;
    gmGridView.delegate = self;
    [self.view addSubview:gmGridView];
    groupGridView = gmGridView;
    //
    titleView = [[UIView alloc] initWithFrame:CGRectMake(10, 5, self.view.frame.size.width-20, WizNavigationTtitleHeaderHeight)];

    [groupGridView addSubview:titleView];
    
    UIImageView* logolImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, 40, WizNavigationTtitleHeaderHeight)];
    logolImageView.image = [UIImage imageNamed:@"logloImage"];

    [titleView addSubview:logolImageView];
    [logolImageView release];
    UIButton* logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    float logoButtonWidth = 90;
    UILabel* loginLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 20, logoButtonWidth, 20)];

    loginLabel.highlightedTextColor = [UIColor lightTextColor];
    loginLabel.adjustsFontSizeToFitWidth = YES;
    NSString* activeUserId = [[WizAccountManager defaultManager] activeAccountUserId];
    if ([activeUserId isEqualToString:WGDefaultChineseUserName]) {
        loginLabel.text = NSLocalizedString(@"Login", nil);
    }
    else
    {
        loginLabel.text = activeUserId;
    }
    
    loginLabel.textAlignment = UITextAlignmentCenter;
    [logoButton addSubview:loginLabel];
    [loginLabel release];
    
    UIImageView* logoWordImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, logoButtonWidth, 20)];
    logoWordImageView.backgroundColor = [UIColor lightGrayColor];
    logoWordImageView.image = [UIImage imageNamed:@"logoWords"];
    [logoButton addSubview:logoWordImageView];
    [logoWordImageView release];
    
    //
    [logoButton addTarget:self action:@selector(clientLogin) forControlEvents:UIControlEventTouchUpInside];
    logoButton.frame = CGRectMake(40, 0.0, logoButtonWidth, WizNavigationTtitleHeaderHeight);
    [titleView addSubview:logoButton];
    
    [gmGridView addSubview:titleView];
}
- (void) clearGroupView
{
    [groupsArray removeAllObjects];
    [groupGridView reloadData];
}

- (void) reloadAllGroups
{
    [self reloadGroupView];
//    [groupGridView.refreshHeaderView startLoadingAnimation:groupGridView];
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

- (void) settingApp
{
    CATransition *tran = [CATransition animation];
    tran.duration = .4f;
    tran.type = @"oglFlip";
    tran.subtype = kCATransitionFromLeft; //Bottom for the opposite direction
    tran.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    tran.removedOnCompletion  = YES;
    [self.navigationController.view.layer addAnimation:tran forKey:@"oglFlip"];
    
    WGSettingViewController* settingController = [[WGSettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:settingController animated:YES];
    [settingController release];
}

- (void) clientLogin
{
    WGLoginViewController* login = [[WGLoginViewController alloc] init];
    [self.navigationController pushViewController:login animated:YES];
    [login release];
}

- (void) setupToolBar
{
    
    UIButton* setButton = [UIButton buttonWithType:UIButtonTypeCustom];
    setButton.frame = CGRectMake(0.0, 0.0, 30, 30);
    [setButton setBackgroundImage:[UIImage imageNamed:@"settingButtonImageClicked"] forState:UIControlStateHighlighted];
    [setButton addTarget:self action:@selector(settingApp) forControlEvents:UIControlEventTouchUpInside];
    [setButton setImage:[UIImage imageNamed:@"settingButtonImage"] forState:UIControlStateNormal];
    [setButton setTitle:@"ss" forState:UIControlStateNormal];
    
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:setButton];
    WGToolBar* toolBar = [[WGToolBar alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
    [toolBar setItems:@[item]];
    [self.view addSubview:toolBar];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupToolBar];
    
    groupGridView.mainSuperView = self.navigationController.view;
    groupGridView.dataSource = self;
    groupGridView.actionDelegate = self;
    if (groupsArray == nil) {
        groupsArray = [[NSMutableArray alloc] init];
    }

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
    
    //

}

- (NSInteger) numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [groupsArray count];
}
- (CGSize) GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(147.5 , 147.5);
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
    NSString* userId = [[WizAccountManager defaultManager] activeAccountUserId];
    [[WizSyncCenter defaultCenter] refreshGroupsListFor:userId];
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [groupGridView reloadData];
    [self.navigationController setNavigationBarHidden:YES];
}
@end
