//
//  TreeNode.m
//  Wiz
//
//  Created by wiz on 12-8-16.
//
//

#import "TreeNode.h"

@implementation TreeNode
@synthesize parentTreeNode;
@synthesize keyString;
@synthesize deep;
@synthesize childrenNodes = childrenNodes_;
@synthesize isExpanded;
@synthesize title;
@synthesize keyPath;
@synthesize strType;
- (void) dealloc
{
    [strType release];
    self.keyPath = nil;
    self.parentTreeNode = nil;
    self.keyString = nil;
    self.title = nil;
    [childrenNodes_ release];
    [super dealloc];
}

- (id) init
{
    self = [super init];
    if (self) {
        childrenNodes_ = [[NSMutableArray alloc] init];
        deep = 0;
        isExpanded = NO;
    }
    return self;
}

- (BOOL) hasChildTreeNode:(NSString*)strKey
{
    if ([self childNodeFromKeyString:strKey]) {
        return YES;
    }
    return NO;
}

- (void) addChildTreeNode:(TreeNode*)node
{
    if ([self hasChildTreeNode:node.keyString]) {
        return;
    }
    node.parentTreeNode = self;
    node.deep = self.deep+1;
    [childrenNodes_ addObject:node];
    [childrenNodes_ sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 isKindOfClass:[TreeNode class]]) {
            TreeNode* n1 = (TreeNode*)obj1;
            TreeNode* n2 = (TreeNode*)obj2;
            return [n1.title compareChinesePinyin:n2.title];
        }
        return 0;
    }];
}

- (void) removeChildTreeNode:(TreeNode*)node
{
    [childrenNodes_ removeObject:node];
    node.parentTreeNode = nil;
}

- (void) expandedTreeNodes:(NSMutableArray*)children
{
    if (self.isExpanded) {
        for (TreeNode* eachNode in childrenNodes_) {
            [children addObject:eachNode];
            [eachNode expandedTreeNodes:children];
        }
    }
}

- (TreeNode*) childNodeFromKeyString:(NSString*)key
{
    for (TreeNode* eachNode in childrenNodes_) {
        if ([eachNode.keyString isEqual:key]) {
            return eachNode;
        }
        TreeNode* node = [eachNode childNodeFromKeyString:key];
        if (nil != node) {
            return node;
        }
    }
    return nil;
}

- (NSArray*) allExpandedChildrenNodes
{
    NSMutableArray* expandedChildren = [NSMutableArray array];
    [self expandedTreeNodes:expandedChildren];
    return expandedChildren;
}

- (NSArray*) allChildren
{
    NSMutableArray* array = [NSMutableArray array];
    for (TreeNode* treeNode in childrenNodes_) {
        [array addObject:treeNode];
        NSArray* arrayChild = [treeNode allChildren];
        if (arrayChild) {
            [array addObjectsFromArray:arrayChild];
        }
    }
    return array;
}

- (void) removeAllChildrenNodes
{
    [childrenNodes_ removeAllObjects];
}

- (void) displayDescription
{
    NSLog(@"self is %@ , %@",self.title,self.keyString);
    for (TreeNode* each in childrenNodes_) {
        [each displayDescription];
    }
}
@end
