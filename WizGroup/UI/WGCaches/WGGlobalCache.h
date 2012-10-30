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
- (void) didGetImage:(UIImage*)image forKbguid:(NSString*)kbguid;
@end

@protocol WizUnreadCountDelegate <NSObject>
- (void) didGetUnreadCountForKbguid:(NSString*)kbguid  unreadCount:(int64_t)count;
@end

@interface WGGlobalCache : NSCache

- (void) getAbstractImageForKbguid:(NSString*)kbguid
                     accountUserId:(NSString*)accountUserId
                          observer:(id<WGIMageCacheObserver>)observer;
- (void) clearAbstractImageForKbguid:(NSString*)kbguid
                       accountUserId:(NSString*)accountUserId;
//
+ (id) shareInstance;
- (BOOL) generateAbstractForDocument:(NSString*)documengGuid
                       accountUserId:(NSString*)accountUserId;

+ (void) getUnreadCountByKbguid:(NSString*) kbguid
                     accountUserId:(NSString*)accountUserId
                          observer:(id<WizUnreadCountDelegate>)delegate;
+ (void)    clearUnreadCountByKbguid:(NSString*) kbguid
                       accountUserId:(NSString*)userId;


+ (WizAbstract*) abstractForDoc:(NSString*)docguid kbguid:(NSString*)kbguid accountUserId:(NSString*)userId;
+ (void) clearAbstractForDocument:(NSString*)docguid;
@end
