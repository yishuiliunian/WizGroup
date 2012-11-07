//
//  WGSettingViewController.m
//  WizGroup
//
//  Created by wiz on 12-10-29.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WGSettingViewController.h"
#import "WGBarButtonItem.h"
#import <QuartzCore/QuartzCore.h>
#import "WizAccountManager.h"
#import "WGLoginViewController.h"
#import "SVModalWebViewController.h"
#import "WizFileManager.h"

//
#import <MessageUI/MessageUI.h>

typedef enum _WGSettingSectionIndex {
    WGSettingSectionIndexAccount = 0,
    WGSettingSectionIndexNetwork = 9,
    WGSettingSectionIndexAbout  =1,
    WGsettingSectionIndexCount = 2
} WGSettingSectionIndex;

@interface WGSettingViewController () <MFMailComposeViewControllerDelegate>
@property (nonatomic, retain) NSMutableArray* settingsArray;
@end

@implementation WGSettingViewController
@synthesize settingsArray;
- (void) dealloc
{
    [settingsArray release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void) reloadSettings
{
   
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem* backItem = [WGBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"loginBackArrow"] hightedImage:nil target:self selector:@selector(popSelf)];
    self.navigationItem.leftBarButtonItem = backItem;

    self.tableView.backgroundColor = [UIColor whiteColor];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return WGsettingSectionIndexCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == WGSettingSectionIndexAbout) {
        return 3;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
    
    //
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    if (indexPath.section == WGSettingSectionIndexNetwork) {
        if (indexPath.row == 0) {
            cell.textLabel.text =WizStrSyncOnlgByWifi;
        }
    }
    else if (indexPath.section == WGSettingSectionIndexAbout)
    {
        if (indexPath.row == 0) {
            cell.textLabel.text =  NSLocalizedString(@"Feedback", nil);
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"Log", nil);
        }
        else if (indexPath.row == 2)
        {
            cell.textLabel.text = NSLocalizedString(@"Version", nil);
            cell.detailTextLabel.text = [WizGlobals wizNoteVersion];
        }
    }
    else if (indexPath.section == WGSettingSectionIndexAccount)
    {
        if (indexPath.row == 0) {
            NSString* activeUserId = [[WizAccountManager defaultManager] activeAccountUserId];
            if ([activeUserId isEqualToString:WGDefaultAccountUserId]) {
                cell.textLabel.text = WizStrLogIn;
            }
            else
            {
                cell.textLabel.text = NSLocalizedString(@"Change User", nil);
            }
 
        }
    }
    return cell;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == WGSettingSectionIndexAccount) {
        NSString* activeUserId = [[WizAccountManager defaultManager] activeAccountUserId];
        if ([activeUserId isEqualToString:WGDefaultAccountUserId]) {
            return  WizStrLogIn;
        }
        else
        {
            return activeUserId;
        }
    }
    return nil;
}

- (void) popSelf
{
    CATransition *tran = [CATransition animation];
    tran.duration = .4f;
    tran.type = @"oglFlip";
    tran.subtype = kCATransitionFromLeft; //Bottom for the opposite direction
    tran.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    tran.removedOnCompletion  = YES;
    [self.navigationController.view.layer addAnimation:tran forKey:@"oglFlip"];
    [self.navigationController popViewControllerAnimated:YES];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void) clientLogin
{
    WGLoginViewController* login = [[WGLoginViewController alloc] init];
    [self.navigationController pushViewController:login animated:YES];
    [login release];
    
}
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissModalViewControllerAnimated:YES];
}
- (void) userFeedback
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* mailPocker = [[MFMailComposeViewController alloc] init];
        mailPocker.mailComposeDelegate = self;
        [mailPocker setSubject:[NSString stringWithFormat:@"[%@] %@ by %@",[[UIDevice currentDevice] model],NSLocalizedString(@"Feedback", nil),[[WizAccountManager defaultManager] activeAccountUserId]]];
        NSArray* toRecipients = [NSArray arrayWithObjects:@"support@wiz.cn",@"ios@wiz.cn",nil];
        NSString* mailBody = [NSString stringWithFormat:@"%@:\n\n\n\n\n\n\n\n\n\n\n\n\n\n %@\n %@ \n%@"
                              ,NSLocalizedString(@"Your advice", nil)
                              ,[[UIDevice currentDevice] systemName]
                              ,[[UIDevice currentDevice] systemVersion]
                              ,[WizGlobals wizNoteVersion]];
        [mailPocker setToRecipients:toRecipients];
        [mailPocker setMessageBody:mailBody isHTML:NO];
        //
        NSString* logFilePath = [WizFileManager logFilePath];
        NSData* logData = [NSData dataWithContentsOfFile:logFilePath];
        [mailPocker addAttachmentData:logData mimeType:@"txt" fileName:@"log.txt"];
        mailPocker.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentModalViewController: mailPocker animated:YES];
        [mailPocker release];
    }
}

- (void) showAppRunLog
{
    NSString* logFile = [WizFileManager logFilePath];
    NSURL* url = [NSURL fileURLWithPath:logFile];
    SVModalWebViewController* webController = [[SVModalWebViewController alloc] initWithURL:url];
    [self.navigationController presentModalViewController:webController animated:YES];
    [webController release];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == WGSettingSectionIndexNetwork) {
        if (indexPath.row == 0) {
        }
    }
    else if (indexPath.section == WGSettingSectionIndexAbout)
    {
        if (indexPath.row == 0) {
            [self userFeedback];
        }
        else if (indexPath.row == 1)
        {
            [self showAppRunLog];
        }
        else if (indexPath.row == 2)
        {
        }
    }
    else if (indexPath.section == WGSettingSectionIndexAccount)
    {
        if (indexPath.row == 0) {
            NSString* activeUserId = [[WizAccountManager defaultManager] activeAccountUserId];
            if ([activeUserId isEqualToString:WGDefaultAccountUserId]) {
                [self clientLogin];
            }
            else
            {
                [self clientLogin];
            }
            
        }
    }

}
- (void) sendFeedback
{
    
}

//
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

@end
