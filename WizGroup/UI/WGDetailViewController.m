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

@interface WGDetailViewController () <WizPadTreeTableCellDelegate>
{
    TreeNode* rootTreeNode;
    NSMutableArray* needDisplayTreeNodes;
}
@end

@implementation WGDetailViewController

@synthesize kbGuid;
@synthesize accountUserId;

- (void) dealloc
{
    [kbGuid release];
    [accountUserId release];
    [super dealloc];
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
        needDisplayTreeNodes = [[NSMutableArray array] retain];
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
                }
            }
            [self addTagTreeNodeToParent:parent rootNode:root allTags:allTags];
            parentNode = [root childNodeFromKeyString:parent.strParentGUID];
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
    [needDisplayTreeNodes removeAllObjects];
    [needDisplayTreeNodes addObjectsFromArray:[rootTreeNode allExpandedChildrenNodes]];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadAllData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [needDisplayTreeNodes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WizPadTreeTableCell";
    WizPadTreeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (nil == cell) {
        cell = [[[WizPadTreeTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.delegate = self;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    TreeNode* node = [needDisplayTreeNodes objectAtIndex:indexPath.row];
    cell.strTreeNodeKey = node.keyString;
    return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    WizPadTreeTableCell* treeCell = (WizPadTreeTableCell*)cell;
    [treeCell showExpandedIndicatory];
    [treeCell setNeedsDisplay];
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
        [needDisplayTreeNodes removeAllObjects];
        [self.tableView reloadData];
    }
    else
    {
        rootTreeNode.isExpanded = !rootTreeNode.isExpanded;
        [needDisplayTreeNodes removeAllObjects];
        [needDisplayTreeNodes addObjectsFromArray:[rootTreeNode allExpandedChildrenNodes]];
        [self.tableView reloadData];
    }
    ;
}

- (void) onExpandedNode:(TreeNode *)node
{
    NSInteger row = NSNotFound;
    for (int i = 0 ; i < [needDisplayTreeNodes count]; i++) {
        
        TreeNode* eachNode = [needDisplayTreeNodes objectAtIndex:i];
        if ([eachNode.keyString isEqualToString:node.keyString]) {
            row = i;
            break;
        }
    }
    if(row != NSNotFound)
    {
        [self onExpandNode:node refrenceIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    }
}

- (void) onExpandNode:(TreeNode*)node refrenceIndexPath:(NSIndexPath*)indexPath
{
    
    if (!node.isExpanded) {
        node.isExpanded = YES;
        NSArray* array = [node allExpandedChildrenNodes];
        
        NSInteger startPostion = [needDisplayTreeNodes count] == 0? 0: indexPath.row+1;
        
        NSMutableArray* rows = [NSMutableArray array];
        for (int i = 0; i < [array count]; i++) {
            NSInteger  positionRow = startPostion+ i;
            
            TreeNode* node = [array objectAtIndex:i];
            [needDisplayTreeNodes insertObject:node atIndex:positionRow];
            
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
        for (int i = indexPath.row; i < [needDisplayTreeNodes count]; i++) {
            TreeNode* displayedNode = [needDisplayTreeNodes objectAtIndex:i];
            if ([node childNodeFromKeyString:displayedNode.keyString]) {
                [deletedIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
                [deletedNodes addObject:displayedNode];
            }
        }
        
        for (TreeNode* each in deletedNodes) {
            [needDisplayTreeNodes removeObject:each];
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
    TreeNode* node = [needDisplayTreeNodes objectAtIndex:indexPath.row];
    
    UINavigationController* navCon = (UINavigationController*) self.revealSideViewController.rootViewController ;
    
    for (UIViewController* each in navCon.viewControllers) {
        if ([each isKindOfClass:[WGListViewController class]]) {
            WGListViewController* listController = (WGListViewController*)each;
            listController.listType = WGListTypeTag;
            listController.listKey = node.keyString;
            break;
        }
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"detail appeared");
}

@end
