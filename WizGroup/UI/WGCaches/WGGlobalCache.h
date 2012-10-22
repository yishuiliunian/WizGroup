//
//  WGGlobalCache.h
//  WizGroup
//
//  Created by wiz on 12-10-18.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizAbstract.h"

@protocol WGIMageCacheObserver <NSObject>
- (void) didGetImage:(UIImage*)image;
@end

@interface WGGlobalCache : NSCache
- (BOOL) generateImageForKbguid:(NSString*)kbguid;
- (UIImage*) imageForGroupKbguid:(NSString *)kbguid;
+ (id) shareInstance;
- (WizAbstract*) abstractForGuid:(NSString*)guid;
- (BOOL) generateAbstractForDocument:(NSString*)documengGuid    accountUserId:(NSString*)accountUserId;
@end
