//
//  WGDetailViewController.m
//  WizGroup
//
//  Created by wiz on 12-9-29.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WGDetailViewController.h"
#import "TreeNode.h"
#import "WizPadTreeTableCell.h"
#import "WizDbManager.h"
#import "WGListViewController.h"
#import "PPRevealSideViewController.h"
#import "WizAccountManager.h"

enum WGFolderListIndex {
    WGFolderListIndexOfCustom = 0,
    WGFolderListIndexOfUserTree = 1
    };

@interface WGDetailViewController () <WizPadTreeTableCellDelegate>
{
    TreeNode* rootTreeNode;
    NSMutableArray* allNodes;
    
    UIView* titleView;
}
@property (nonatomic, assign, getter = needDisplayNodesArray) NSMutableArray* needDisplayNodesArray;
@end

@implementation WGDetailViewController

@synthesize kbGuid;
@synthesize accountUserId;
- (void) dealloc
{
    [titleView release];
    [allNodes release];
    [rootTreeNode release];
    [kbGuid release];
    [accountUserId release];
    [super dealloc];
}
- (NSMutableArray*) needDisplayNodesArray
{
    return [allNodes objectAtIndex:WGFolderListIndexOfUserTree];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        TreeNode* folderRootNode = [[TreeNode alloc] init];
        folderRootNode.title   = @"key";
        folderRootNode.keyString = @"key";
        folderRootNode.isExpanded = YES;
        rootTreeNode = folderRootNode;
        NSMutableArray* needDisplayTreeNodes = [NSMutableArray array] ;
        //
        NSMutableArray*  customNodes = [NSMutableArray array];
        //
        [customNodes addObject:NSLocalizedString(@"Rectent Notes", nil)];
        [customNodes addObject:NSLocalizedString(@"Unread Notes", nil)];
        allNodes = [[NSMutableArray array] retain];
        [allNodes addObject:customNodes];
        [allNodes addObject:needDisplayTreeNodes];
        
        //
        titleView = [[UIView alloc] init];
    }
    return self;
}
- (void) addTagTreeNodeToParent:(WizTag*)tag   rootNode:(TreeNode*)root  allTags:(NSArray*)allTags
{
    TreeNode* node = [[TreeNode alloc] init];
    node.title = tag.strTitle;
    node.keyString = tag.strGuid;
    node.isExpanded = NO;
    node.strType = WizTreeViewTagKeyString;
    if (tag.strParentGUID == nil || [tag.strParentGUID isEqual:@""]) {
        [root addChildTreeNode:node];
    }
    else
    {
        TreeNode* parentNode = [root childNodeFromKeyString:tag.strParentGUID];
        if(nil != parentNode)
        {
            [parentNode addChildTreeNode:node];
        }
        else
        {
            WizTag* parent = nil;
            for (WizTag* each in allTags) {
                if ([each.strGuid isEqualToString:tag.strParentGUID]) {
                    parent = each;
                    break;
                }
            }
            [self addTagTreeNodeToParent:parent rootNode:root allTags:allTags];
            parentNode = [root childNodeFromKeyString:tag.strParentGUID];
            [parentNode addChildTreeNode:node];
        }
    }
    [node release];
}

- (void) reloadTagRootNode
{
    
    NSArray* tagArray = [[[WizDbManager shareInstance] getMetaDataBaseForAccount:self.accountUserId kbGuid:self.kbGuid ] allTagsForTree];
    TreeNode* tagRootNode = rootTreeNode;
    
    [tagRootNode removeAllChildrenNodes];
    
    for (WizTag* each in tagArray) {
        if (each.strTitle != nil && ![each.strTitle isEqualToString:@""]) {
            [self addTagTreeNodeToParent:each rootNode:tagRootNode allTags:tagArray];
        }
    }
}
- (void )reloadAllTreeNodes
{
    [self reloadTagRootNode];
}

- (void) reloadAllData
{
    [self reloadAllTreeNodes];
    [self.needDisplayNodesArray removeAllObjects];
    [self.needDisplayNodesArray addObjectsFromArray:[rootTreeNode allExpandedChildrenNodes]];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadAllData];
     [self loadTitleView];
}

- (void) loadTitleView
{
    titleView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 80);
    self.tableView.tableHeaderView = titleView;
    titleView.backgroundColor = [UIColor whiteColor];
    
    WizGroup* group = [[WizAccountManager defaultManager] groupForKbguid:self.kbGuid accountUserId:self.accountUserId];
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20 -DefaultOffset, 30)];
    titleLabel.text = group.kbName;
    [titleView addSubview:titleLabel];
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel release];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [allNodes count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[allNodes objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == WGFolderListIndexOfUserTree) {
        static NSString *CellIdentifier = @"WizPadTreeTableCell";
        WizPadTreeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (nil == cell) {
            cell = [[[WizPadTreeTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            cell.delegate = self;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        if (indexPath.section == WGFolderListIndexOfUserTree) {
            TreeNode* node = [self.needDisplayNodesArray objectAtIndex:indexPath.row];
            cell.strTreeNodeKey = node.keyString;
        }
        
        return cell;
    }
    else
    {
        static NSString* CellIndentifier2 = @"CellIndentifier2";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier2];
        if(!cell)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIndentifier2] autorelease];
        }
        cell.textLabel.text = [[allNodes objectAtIndex:WGFolderListIndexOfCustom] objectAtIndex:indexPath.row];
        return cell;
    }

}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == WGFolderListIndexOfUserTree) {
        WizPadTreeTableCell* treeCell = (WizPadTreeTableCell*)cell;
        [treeCell showExpandedIndicatory];
        [treeCell setNeedsDisplay];
    }
}

- (TreeNode*) findTreeNodeByKey:(NSString*)strKey
{
    return [rootTreeNode childNodeFromKeyString:strKey];
}

- (void) onexpandedRootNode
{
    NSLog(@"%d",rootTreeNode.isExpanded);
    if (rootTreeNode.isExpanded) {
        rootTreeNode.isExpanded = !rootTreeNode.isExpanded;
        [self.needDisplayNodesArray removeAllObjects];
        [self.tableView reloadData];
    }
    else
    {
        rootTreeNode.isExpanded = !rootTreeNode.isExpanded;
        [self.needDisplayNodesArray removeAllObjects];
        [self.needDisplayNodesArray addObjectsFromArray:[rootTreeNode allExpandedChildrenNodes]];
        [self.tableView reloadData];
    }
    ;
}

- (void) onExpandedNode:(TreeNode *)node
{
    NSInteger row = NSNotFound;
    for (int i = 0 ; i < [self.needDisplayNodesArray count]; i++) {
        
        TreeNode* eachNode = [self.needDisplayNodesArray objectAtIndex:i];
        if ([eachNode.keyString isEqualToString:node.keyString]) {
            row = i;
            break;
        }
    }
    if(row != NSNotFound)
    {
        [self onExpandNode:node refrenceIndexPath:[NSIndexPath indexPathForRow:row inSection:WGFolderListIndexOfUserTree]];
    }
}

- (void) onExpandNode:(TreeNode*)node refrenceIndexPath:(NSIndexPath*)indexPath
{
    
    if (!node.isExpanded) {
        node.isExpanded = YES;
        NSArray* array = [node allExpandedChildrenNodes];
        
        NSInteger startPostion = [self.needDisplayNodesArray count] == 0? 0: indexPath.row+1;
        
        NSMutableArray* rows = [NSMutableArray array];
        for (int i = 0; i < [array count]; i++) {
            NSInteger  positionRow = startPostion+ i;
            
            TreeNode* node = [array objectAtIndex:i];
            [self.needDisplayNodesArray insertObject:node atIndex:positionRow];
            
            [rows addObject:[NSIndexPath indexPathForRow:positionRow inSection:indexPath.section]];
        }
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
    else
    {
        node.isExpanded = NO;
        NSMutableArray* deletedIndexPaths = [NSMutableArray array];
        NSMutableArray* deletedNodes = [NSMutableArray array];
        for (int i = indexPath.row; i < [self.needDisplayNodesArray count]; i++) {
            TreeNode* displayedNode = [self.needDisplayNodesArray objectAtIndex:i];
            if ([node childNodeFromKeyString:displayedNode.keyString]) {
                [deletedIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
                [deletedNodes addObject:displayedNode];
            }
        }
        
        for (TreeNode* each in deletedNodes) {
            [self.needDisplayNodesArray removeObject:each];
        }
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:deletedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

- (UIImage*) placeHolderImage
{
    return nil;
}
- (void) showExpandedIndicatory:(WizPadTreeTableCell*)cell
{
    TreeNode* node = [self findTreeNodeByKey:cell.strTreeNodeKey];
    if ([node.childrenNodes count]) {
        if (!node.isExpanded) {
            [cell.expandedButton setImage:[UIImage imageNamed:@"treePhoneItemClosed"] forState:UIControlStateNormal];
        }
        else
        {
            [cell.expandedButton setImage:[UIImage imageNamed:@"treePhoneItemOpened"] forState:UIControlStateNormal];
        }
    }
    else
    {
        [cell.expandedButton setImage:[self placeHolderImage] forState:UIControlStateNormal];
    }
}
- (void) onExpandedNodeByKey:(NSString*)strKey
{
    TreeNode* node = [self findTreeNodeByKey:strKey];
    if (node) {
        [self onExpandedNode:node];
    }
}
- (NSInteger) treeNodeDeep:(NSString*)strKey
{
    TreeNode* node = [self findTreeNodeByKey:strKey];
    return node.deep;
}

- (void) decorateTreeCell:(WizPadTreeTableCell *)cell
{
    TreeNode* node = [rootTreeNode childNodeFromKeyString:cell.strTreeNodeKey];
    if (node == nil) {
        return;
    }
    cell.titleLabel.text = getTagDisplayName(node.title);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* listKeyStr = nil;
    NSInteger listType = 0;
    if (indexPath.section == WGFolderListIndexOfUserTree) {
        TreeNode* node = [self.needDisplayNodesArray objectAtIndex:indexPath.row];
        listType = WGListTypeTag;
        listKeyStr = node.keyString;
    }
    else
    {
        switch (indexPath.row) {
            case 0:
                listType = WGListTypeRecent;
                listKeyStr = nil;
                break;
            case 1:
                listType = WGListTypeUnread;
                listKeyStr = nil;
                break;
            default:
                break;
        }
    }
    UINavigationController* navCon = (UINavigationController*) self.revealSideViewController.rootViewController ;
    for (UIViewController* each in navCon.viewControllers) {
        if ([each isKindOfClass:[WGListViewController class]]) {
            WGListViewController* listController = (WGListViewController*)each;
            listController.listType = listType;
            listController.listKey = listKeyStr;
            break;
        }
    }
}
- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == WGFolderListIndexOfCustom) {
        return NSLocalizedString(@"Custom", nil);
    }
    else if (section == WGFolderListIndexOfUserTree)
    {
        return NSLocalizedString(@"Folder", nil);
    }
    return nil;
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"detail appeared");
}

@end
