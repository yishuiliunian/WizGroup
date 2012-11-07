//
//  WGAppDelegate.m
//  WizGroup
//
//  Created by wiz on 12-9-29.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WGAppDelegate.h"
#import "WGMainViewController.h"
#import "WizAccountManager.h"
#import "WizSettingsDataBase.h"
#import "WizFileManager.h"
#import "WizGlobals.h"
static void handleRootException ( NSException* exception)
{
    NSString* name = [ exception name ];
    NSString* reason = [ exception reason ];
    NSArray* symbols = [ exception callStackSymbols ]; // 异常发生时的调用栈
    NSMutableString* strSymbols = [ [ NSMutableString alloc ] init ]; // 将调用栈拼成输出日志的字符串
    for ( NSString* item in symbols )
    {
        [ strSymbols appendString: item ];
        [ strSymbols appendString: @"\r\n" ];
    }
    
    // 写日志，级别为ERROR
    writeCinLog( __FUNCTION__, WizLogLevelError, @"[ Uncaught Exception ]\r\nName: %@, Reason: %@\r\n[ Fe Symbols Start ]\r\n%@[ Fe Symbols End ]", name, reason, strSymbols );
    [ strSymbols release ];
    
    
    // 这儿必须Hold住当前线程，等待日志线程将日志成功输出，当前线程再继续运行
    sleep(1.0);

    // 写一个文件，记录此时此刻发生了异常。这个挺有用的哦
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:WizCrashHanppend];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@implementation WGAppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (void) showLastCrash
{
    BOOL isCrash = [[NSUserDefaults standardUserDefaults] boolForKey:WizCrashHanppend];
    if (isCrash) {
        NSLog(@"crash******");
    }
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:WizCrashHanppend];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSSetUncaughtExceptionHandler(handleRootException);
    [self showLastCrash];
    WizAccountManager* accountManager = [WizAccountManager defaultManager];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    WGMainViewController* mainController = [[WGMainViewController alloc] init];
    
    NSString* activeAccountUserId = [accountManager activeAccountUserId];
    [accountManager registerActiveAccount:activeAccountUserId];
    
    UINavigationController* root = [[UINavigationController alloc] initWithRootViewController:mainController];
    
    [mainController release];
    self.rootControll = root;
    [root release];
    [self.window addSubview:self.rootControll.view];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
