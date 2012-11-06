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
#import "WGNavigationBar.h"
#import "PPRevealSideViewController.h"

#import "WGDetailViewController.h"
#import "WGListViewController.h"

#import "WizSyncCenter.h"

#import "WGGlobalCache.h"

#import "UINavigationBar+WizCustom.h"

#import "WizDbManager.h"
//
#import "WGToolBar.h"

#import "WGNavigationViewController.h"
//
#import "WGBarButtonItem.h"

//
#define WGGroupListRefreshButtonTag 3934

@interface WGMainViewController () <GMGridViewDataSource, GMGridViewActionDelegate, EGORefreshTableHeaderDelegate, UIScrollViewDelegate>
{
    GMGridView* groupGridView;
    NSMutableArray* groupsArray;
    //
    UIView*     titleView;
    BOOL    isRefreshing;
}
@property (nonatomic, retain) UILabel* userNameLabel;
@property (atomic, assign) NSInteger numberOfSyncingGroups;
@property (nonatomic, retain) UIButton* refreshButton;
@property (nonatomic, retain) UIImageView* refreshImageView;
@end

@implementation WGMainViewController

@synthesize numberOfSyncingGroups;
@synthesize userNameLabel;
@synthesize refreshButton;
@synthesize refreshImageView;

- (void) dealloc
{
    [[WizNotificationCenter defaultCenter] removeObserver:self];
    [titleView release];
    [groupGridView release];
    [groupsArray release];
    [userNameLabel release];
    //
    [refreshImageView release];
    [refreshButton release];
    //
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
        [self showReloadButton];
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
    [self refreshGroupData];
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
- (void) loadActiveAccountName
{
    NSString* activeUserId = [[WizAccountManager defaultManager] activeAccountUserId];
    if ([activeUserId isEqualToString:WGDefaultAccountUserId]) {
        self.userNameLabel.text = NSLocalizedString(@"Click To Login", nil);
    }
    else
    {
        self.userNameLabel.text = activeUserId;
    }
    
}
- (void) loadView
{
    [super loadView];
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
    gmGridView.backgroundColor = WGDetailCellBackgroudColor;
    [self.view addSubview:gmGridView];
    groupGridView = gmGridView;
    //
    titleView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width-20, 30)];

    [groupGridView addSubview:titleView];
    
    UIImageView* logolImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, 40, 40)];
    logolImageView.image = [UIImage imageNamed:@"group_list_logol"];

    [titleView addSubview:logolImageView];
    [logolImageView release];
    UIButton* logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    float logoButtonWidth = 180;
    UILabel* loginLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 21, logoButtonWidth, 20)];
    self.userNameLabel = loginLabel;
    loginLabel.backgroundColor = [UIColor clearColor];
    loginLabel.adjustsFontSizeToFitWidth = YES;

    loginLabel.textAlignment = UITextAlignmentLeft;
    [logoButton addSubview:loginLabel];
    [loginLabel release];
    
    UIImageView* logoWordImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 90, 20)];
    logoWordImageView.image = [UIImage imageNamed:@"group_list_logol_words"];
    [logoButton addSubview:logoWordImageView];
    [logoWordImageView release];
    
    //
    [logoButton addTarget:self action:@selector(clientLogin) forControlEvents:UIControlEventTouchUpInside];
    logoButton.frame = CGRectMake(45, 0.0, logoButtonWidth, WizNavigationTtitleHeaderHeight);
    [titleView addSubview:logoButton];
    
    titleView.backgroundColor = WGDetailCellBackgroudColor;
    [self showReloadButton];
    //

    //
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
    isRefreshing = YES;
    [groupGridView.refreshHeaderView startLoadingAnimation:groupGridView];
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

- (void) userCenter
{
    
}
- (void) setupToolBar
{
    
    UIBarButtonItem* setItem = [WGBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"group_list_settings"] hightedImage:nil target:self selector:@selector(settingApp)];
    
    WGToolBar* toolBar = [[WGToolBar alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
    
    UIBarButtonItem* flexItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    
    UIBarButtonItem* userCenterItem = [WGBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"listUsersIcon"] hightedImage:nil target:self selector:@selector(userCenter)];
    
    [toolBar setItems:@[setItem, flexItem, userCenterItem]];
    [self.view addSubview:toolBar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupToolBar];
    
    //
    
    WGNavigationBar* navBar = [[[WGNavigationBar alloc] init] autorelease];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor blackColor],
                                UITextAttributeTextColor,
                                [UIColor clearColor],
                                UITextAttributeTextShadowColor, nil];
    [navBar setTitleTextAttributes:attributes];
    [self.navigationController setValue:navBar forKeyPath:@"navigationBar"];
    //
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
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = WGGroupListRefreshButtonTag;
    
    
    UIImage* normalImage = [UIImage imageNamed:@"group_list_refresh"];
    UIImage* refreshImage1 = [UIImage imageNamed:@"group_list_refresh1"];
    UIImage* refreshImage2 = [UIImage imageNamed:@"group_list_refresh2"];
    UIImage* refreshImage3 = [UIImage imageNamed:@"group_list_refresh3"];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:normalImage];
    imageView.animationImages = @[normalImage,refreshImage1,refreshImage2,refreshImage3];
    imageView.animationDuration = 0.5;
    //test
    [imageView startAnimating];
    //
    imageView.frame = CGRectMake(5.0, 5.0, 30, 30);
    [button addSubview:imageView];
    button.frame = CGRectMake(titleView.frame.size.width - 50, 0, 40, 40);
    [button addTarget:self
               action:@selector(refreshGroupData)
     forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:button];
    self.refreshButton = button;
    self.refreshImageView = imageView;
    [imageView release];
    //

}

- (NSInteger) numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [groupsArray count] + 1;
}
- (CGSize) GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(147.5 , 120);
}

- (GMGridViewCell*) GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    
    if (index == [groupsArray count]) {
        GMGridViewCell* cell = [[[GMGridViewCell alloc] initWithFrame:CGRectMake(0.0, 0.0, size.width, size.height)] autorelease];
        
        float labelWidth = 100;
        float labelHeight = 20;
        
        
        UILabel* addNewLabel = [[UILabel alloc] initWithFrame:CGRectMake((size.width-labelWidth)/2 + labelHeight, (size.height - labelHeight)/2, labelWidth, labelHeight)];
        

        
        addNewLabel.font = [UIFont systemFontOfSize:16];
        addNewLabel.textColor = [UIColor lightGrayColor];
        addNewLabel.backgroundColor = [UIColor clearColor];
        addNewLabel.text = NSLocalizedString(@"Add Group", nil);
        [cell addSubview:addNewLabel];
        [addNewLabel release];
        //
        UIImageView* addNewImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addNewGroupIcon"]];
        addNewImageView.frame = CGRectMake(addNewLabel.frame.origin.x - labelHeight, addNewLabel.frame.origin.y, labelHeight, labelHeight);
        [cell addSubview:addNewImageView];
        [addNewImageView release];
        //
        cell.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
        return cell;
    }
    
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
    self.refreshButton = nil;
    self.refreshImageView = nil;
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    if (position == [groupsArray count]) {
        
        NSLog(@"add new");
        return;
    }
    
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
    listCon.kbGroup = group;
    //
    WGNavigationViewController* centerNav = [[WGNavigationViewController alloc] initWithRootViewController:listCon];
    
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

- (void) removeOldRefreshButton
{
    for (UIView* each in [titleView subviews]) {
        if (each.tag  == WGGroupListRefreshButtonTag) {
            [each removeFromSuperview];
        }
    }
}

- (void)showReloadButton {
    [self.refreshImageView stopAnimating];
}

- (void)showActivityIndicator {
    [self.refreshImageView startAnimating];
}
- (void) refreshGroupData
{
    NSString* userId = [[WizAccountManager defaultManager] activeAccountUserId];
    [[WizSyncCenter defaultCenter] refreshGroupsListFor:userId];
    [self.refreshImageView startAnimating];
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [groupGridView reloadData];
    [self.navigationController setNavigationBarHidden:YES];
    [self loadActiveAccountName];
}
@end
