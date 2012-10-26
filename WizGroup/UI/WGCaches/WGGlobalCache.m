//
//  WGGlobalCache.m
//  WizGroup
//
//  Created by wiz on 12-10-18.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WGGlobalCache.h"
#import "WizDbManager.h"

#import "WizDbManager.h"
#import "WizFileManager.h"

#define WGUnreadCountClearKey   -1

@interface WGGlobalCache ()
{
    NSMutableDictionary* observersDictionary;
}
@end

@implementation WGGlobalCache

- (void) dealloc
{
    [observersDictionary release];
    [super dealloc];
}

- (id) init
{
    self = [super init];
    if (self) {
        observersDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (id) shareInstance
{
    static WGGlobalCache* shareInstance = nil;
    @synchronized(self)
    {
        if (shareInstance == nil) {
            shareInstance = [[WGGlobalCache alloc] init];
        }
        return shareInstance;
    }
}

- (NSString*) imageKeyForGropuKbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId
{
    return [NSString stringWithFormat:@"%@%@%@",@"groupImage",kbguid,accountUserId];
}

- (void) clearAbstractImageForKbguid:(NSString *)kbguid accountUserId:(NSString *)accountUserId
{
    NSString* key = [self imageKeyForGropuKbguid:kbguid accountUserId:accountUserId];
    [self removeObjectForKey:key];
}

- (void) getAbstractImageForKbguid:(NSString*)kbguid  accountUserId:(NSString*)accountUserId observer:(id<WGIMageCacheObserver>)observer
{
    NSString* key = [self imageKeyForGropuKbguid:kbguid accountUserId:accountUserId];
    UIImage* image = [[WGGlobalCache shareInstance] objectForKey:key];
    if (image) {
        [observer didGetImage:image forKbguid:kbguid];
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        id<WizTemporaryDataBaseDelegate> db = [[WizDbManager shareInstance] getGlobalCacheDb];
        
        UIImage* image = [UIImage imageNamed:@"a.PNG"];
        UIImage* imageData =  [image compressedImageWidth:120];
        @synchronized(self)
        {
            [db updateAbstract:@"asdfasd" imageData:[imageData compressedData] guid:kbguid type:@"adf" kbguid:nil];
            WizAbstract* abstract =  [db abstractFoGuid:kbguid];
            if (abstract != nil) {
                [self setObject:abstract.uiImage forKey:kbguid];
            }
            [self setObject:image forKey:key];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [observer didGetImage:image forKbguid:kbguid];
        });
    });
}


- (BOOL) generateAbstractForDocument:(NSString*)documengGuid    accountUserId:(NSString*)accountUserId
{
    NSString* sourceFilePath = [[WizFileManager shareManager] getDocumentFilePath:DocumentFileIndexName documentGUID:documengGuid accountUserId:accountUserId];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:sourceFilePath]) {
        return NO;
    }
    NSString* abstractText = nil;
    if ([WizGlobals fileLength:sourceFilePath] < 1024*1024) {
        
        NSString* sourceStr = [NSString stringWithContentsOfFile:sourceFilePath usedEncoding:nil error:nil];
        if (sourceStr.length > 1024*50) {
            sourceStr = [sourceStr substringToIndex:1024*50];
        }
        NSString* destStr = [sourceStr htmlToText:200];
        destStr = [destStr stringReplaceUseRegular:@"&(.*?);|\\s|/\n" withString:@""];
        if (destStr == nil || [destStr isEqualToString:@""]) {
            destStr = @"";
        }
        if (WizDeviceIsPad) {
            NSRange range = NSMakeRange(0, 100);
            if (destStr.length <= 100) {
                range = NSMakeRange(0, destStr.length);
            }
            abstractText = [destStr substringWithRange:range];
        }
        else
        {
            NSRange range = NSMakeRange(0, 70);
            if (destStr.length <= 70) {
                range = NSMakeRange(0, destStr.length);
            }
            abstractText = [destStr substringWithRange:range];
        }
    }
    else
    {
        NSLog(@"the file name is %@",sourceFilePath);
    }
    
    
    NSString* sourceImagePath = [[WizFileManager shareManager] documentIndexFilesPath:documengGuid accountUserId:accountUserId];
    NSArray* imageFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sourceImagePath  error:nil];
    
    NSString* maxImageFilePath = nil;
    int maxImageSize = 0;
    for (NSString* each in imageFiles) {
        NSArray* typeArry = [each componentsSeparatedByString:@"."];
        if ([WizGlobals checkAttachmentTypeIsImage:[typeArry lastObject]]) {
            NSString* sourceImageFilePath = [sourceImagePath stringByAppendingPathComponent:each];
            int fileSize = [WizGlobals fileLength:sourceFilePath];
            if (fileSize > maxImageSize && fileSize < 1024*1024) {
                maxImageFilePath = sourceImageFilePath;
            }
        }
    }
    UIImage* compassImage = nil;
    
    //
    if (nil != maxImageFilePath) {
        float compassWidth=140;
        float compassHeight = 140;
        if (WizDeviceIsPad) {
            compassWidth = 350;
            compassHeight = 170;
        }
        UIImage* image = [[UIImage alloc] initWithContentsOfFile:maxImageFilePath];
        
        if (nil != image)
        {
            if (image.size.height >= compassHeight && image.size.width >= compassWidth) {
                compassImage = [image wizCompressedImageWidth:compassWidth height:compassHeight];
            }
            [image release];
        }
    }
    
    NSData* imageData = nil;
    if (nil != compassImage) {
        imageData = [compassImage compressedData];
    }
    WizAbstract* abs = [[WizAbstract alloc] init];
    abs.strText = abstractText;
    abs.uiImage = compassImage;
    id<WizTemporaryDataBaseDelegate> cacheDb = [[WizDbManager shareInstance] getGlobalCacheDb];
    [self setObject:abs forKey:documengGuid];
    [abs release];
    return [cacheDb updateAbstract:abstractText imageData:imageData guid:documengGuid type:@"" kbguid:nil];
}

- (WizAbstract*) abstractForGuid:(NSString *)guid
{
    WizAbstract* abstract = [self objectForKey:guid];
    return abstract;
}
+ (NSString*) unreadCountKey:(NSString*)kbguid  accountUserId:(NSString*)userId
{
    return [NSString stringWithFormat:@"unreandcount%@-%@",kbguid,userId];
}
+ (void) getUnreadCountByKbguid:(NSString *)kbguid accountUserId:(NSString *)accountUserId observer:(id<WizUnreadCountDelegate>)delegate
{
    NSString* key = [self unreadCountKey:kbguid accountUserId:accountUserId];
    NSNumber* unreadCount = [[WGGlobalCache shareInstance] objectForKey:key];
    if (unreadCount && [unreadCount intValue] != WGUnreadCountClearKey) {
        [delegate didGetUnreadCountForKbguid:kbguid unreadCount:[unreadCount intValue]];
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        id<WizMetaDataBaseDelegate> db = [[WizDbManager shareInstance] getMetaDataBaseForAccount:accountUserId kbGuid:kbguid];
        int64_t count = [db documentUnReadCount];
        [[self shareInstance] setObject:[NSNumber numberWithInt:count] forKey:key];
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate didGetUnreadCountForKbguid:kbguid unreadCount:count];
        });
    });
}
+ (void) clearUnreadCountByKbguid:(NSString *)kbguid accountUserId:(NSString *)userId
{
    NSString* key = [self unreadCountKey:kbguid accountUserId:userId];
    [[WGGlobalCache shareInstance] setObject:[NSNumber numberWithInt:WGUnreadCountClearKey] forKey:key];
}
@end
