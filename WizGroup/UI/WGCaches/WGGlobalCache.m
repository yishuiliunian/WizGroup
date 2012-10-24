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

- (BOOL) generateImageForKbguid:(NSString*)kbguid
{
    id<WizTemporaryDataBaseDelegate> db = [[WizDbManager shareInstance] getGlobalCacheDb];

    @synchronized(db)
    {
        UIImage* image = [UIImage imageNamed:@"a.PNG"];
        @synchronized(image)
        {
//            UIImage* imageData =  [image compressedImageWidth:120];
//            [db updateAbstract:@"asdfasd" imageData:[imageData compressedData] guid:kbguid type:@"adf" kbguid:nil];
            WizAbstract* abstract =  [db abstractFoGuid:kbguid];
            [self setObject:abstract.uiImage forKey:kbguid];
        }

    }
    return YES;
}


- (UIImage*) imageForGroupKbguid:(NSString *)kbguid 
{
    UIImage* image = [self objectForKey:kbguid];
    return image;
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
@end
