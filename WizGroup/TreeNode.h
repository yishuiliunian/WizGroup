//
//  TreeNode.h
//  Wiz
//
//  Created by wiz on 12-8-16.
//
//

#import <Foundation/Foundation.h>

@interface TreeNode : NSObject
{
    TreeNode*       parentTreeNode;
    NSString*       keyString;
    NSInteger       deep;
    NSMutableArray* childrenNodes;
    BOOL            isExpanded;
    NSString*       title;
    NSString*       keyPath;
}
@property (nonatomic, retain) NSString*       title;
@property (nonatomic, retain) TreeNode*   parentTreeNode;
@property (nonatomic, retain) NSString*   keyString;
@property (nonatomic, assign) NSInteger   deep;
@property (nonatomic, readonly) NSMutableArray* childrenNodes;
@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, retain) NSString*       keyPath;
@property (nonatomic, retain) NSString*     strType;

- (void) addChildTreeNode:(TreeNode*)node;
- (void) removeChildTreeNode:(TreeNode*)node;
- (NSArray*) allExpandedChildrenNodes;
- (void) removeAllChildrenNodes;
- (TreeNode*) childNodeFromKeyString:(NSString*)key;
- (void) displayDescription;
- (NSArray*) allChildren;
@end
