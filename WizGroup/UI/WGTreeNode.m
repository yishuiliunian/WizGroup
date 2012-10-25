//
//  WGTreeNode.m
//  WizGroup
//
//  Created by wiz on 12-10-25.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WGTreeNode.h"

@implementation WGTreeNode
@synthesize title;
@synthesize isExpanded;
@synthesize parentKeyString;

+ (void) reloadTagDictionary:(NSMutableDictionary*)dic  tags:(NSArray*)tags
{
    NSMutableDictionary* refreshDic = [NSMutableDictionary dictionary];
    for (WizTag* tag in tags) {
        WGTreeNode* node = [dic objectForKey:tag.strGuid];
        if (node) {
            node.title = tag.strTitle;
            [refreshDic setObject:node forKey:tag.strGuid];
        }
        else
        {
            WGTreeNode* tagNode = [[WGTreeNode alloc] init];
            tagNode.title = tag.strTitle;
            tagNode.parentKeyString = tag.strParentGUID;
            tagNode.isExpanded = NO;
            [refreshDic setObject:tagNode forKey:tag.strGuid];
            [tagNode release];
        }
    }
    [dic removeAllObjects];
    [dic addEntriesFromDictionary:refreshDic];
}

+ (NSInteger) deepForNode:(NSString*)keyStr inDic:(NSDictionary*)dic
{
    if (keyStr == nil) {
        return 0;
    }
    WGTreeNode* node = [dic objectForKey:keyStr];
    if (node.parentKeyString == nil) {
        return 1;
    }
    else
    {
        NSInteger deep = [WGTreeNode deepForNode:node.parentKeyString inDic:dic];
        return deep++;
    }
}

+ (void) getAllExpandedChildren:(NSString*)key toArray:(NSMutableArray*)array  inDic:(NSDictionary*)dic
{
    NSMutableArray* children = [NSMutableArray array];
    for (WGTreeNode* eachNode in [dic allValues]) {
        if ([eachNode.parentKeyString isEqualToString:key]) {
            [children addObject:dic];
        }
    }
    
}
@end
