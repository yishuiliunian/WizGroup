//
//  WizPadTreeTableCell.h
//  Wiz
//
//  Created by wiz on 12-8-16.
//
//

#import <UIKit/UIKit.h>
#import "TreeNode.h"

#define WizTreeViewTagKeyString         @"treeTag"
#define WizTreeViewFolderKeyString      @"treeLocation"

@class WizPadTreeTableCell;
@protocol WizPadTreeTableCellDelegate <NSObject>

- (void) showExpandedIndicatory:(WizPadTreeTableCell*)cell;
- (void) onExpandedNodeByKey:(NSString*)strKey;
- (NSInteger) treeNodeDeep:(NSString*)strKey;
- (void) decorateTreeCell:(WizPadTreeTableCell*)cell;
@optional
- (void) didSelectedTheNewTreeNodeButton:(NSString*)strTreeNodeKey;
@end

@interface WizPadTreeTableCell : UITableViewCell
@property (nonatomic, retain)  UIButton*                        expandedButton;
@property (nonatomic, retain)  UILabel*                         titleLabel;
@property (nonatomic, retain)  UILabel*                         detailLabel;
@property (nonatomic, retain)  NSString*                        strTreeNodeKey;
@property (nonatomic, assign)  id<WizPadTreeTableCellDelegate>  delegate;
- (void) showExpandedIndicatory;
@end
