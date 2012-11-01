//
//  WGLoginViewController.m
//  WizGroup
//
//  Created by wiz on 12-10-25.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WGLoginViewController.h"
#import "WizApiClientLogin.h"
#import "WizAccountManager.h"
#import "MBProgressHUD.h"
#import "WGNavigationBar.h"
#import "WGBarButtonItem.h"
#import <QuartzCore/QuartzCore.h>

@interface WGLoginViewController () <WizApiLoginDelegate, UIGestureRecognizerDelegate>
{
    UITextField* usernameTextField;
    UITextField* passwordTextField;
    UIButton* clientLoginButton;
    UIScrollView* backgroudView;
    
    UIView* inputBackgroudView;
}
@property (nonatomic, retain) NSString* userName;
@property (nonatomic, retain) NSString* password;
@property (nonatomic, retain) WizApiClientLogin* checkToolApi;
@end

@implementation WGLoginViewController
@synthesize userName;
@synthesize password;
@synthesize checkToolApi;
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [inputBackgroudView release];
    [backgroudView release];
    [checkToolApi release];
    [userName release];
    [password release];
    [usernameTextField release];
    [passwordTextField release];
    [clientLoginButton release];
    [super dealloc];
}
- (void) resignAllTextField
{
    [usernameTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        usernameTextField = [[UITextField alloc] init];
        usernameTextField.borderStyle = UITextBorderStyleNone;
        usernameTextField.placeholder = NSLocalizedString(@"Username", nil);
        usernameTextField.textAlignment = UITextAlignmentLeft;
        usernameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        
        UIImageView* userImView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user"]];
        userImView.frame = CGRectMake(0.0, 0.0, 30, 30);
        usernameTextField.leftViewMode = UITextFieldViewModeAlways;
        usernameTextField.leftView = userImView;
        [userImView release];
        //
        
        passwordTextField = [[UITextField alloc] init];
        passwordTextField.secureTextEntry = YES;
        passwordTextField.borderStyle = UITextBorderStyleNone;
        passwordTextField.placeholder = NSLocalizedString(@"Password", nil);
        passwordTextField.textAlignment = UITextAlignmentLeft;
        passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        UIImageView* passImView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"password"]];
        passImView.frame = CGRectMake(20, 0.0, 30, 30);
        passwordTextField.leftViewMode = UITextFieldViewModeAlways;
        passwordTextField.leftView = passImView;
        [passImView release];
        //
        inputBackgroudView = [[UIView alloc] init];
        CALayer* layer = inputBackgroudView.layer;
        layer.borderColor = [UIColor lightGrayColor].CGColor;
        layer.borderWidth = 1.0f;
        layer.cornerRadius = 5.0f;
        //
        clientLoginButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
        [clientLoginButton addTarget:self action:@selector(clientLogin) forControlEvents:UIControlEventTouchUpInside];
        [clientLoginButton setTitle:NSLocalizedString(@"Login", nil) forState:UIControlStateNormal];
        //
        backgroudView = [[UIScrollView alloc] init];
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignAllTextField)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        tap.delegate = self;
        [backgroudView addGestureRecognizer:tap];
        [tap release];
        //
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    }
    return self;
}
- (void) keyboardDidShow:(NSNotification*)nc
{
    NSDictionary* dic = [nc userInfo];
    CGRect rect = [[dic objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    backgroudView.frame = CGRectMake(0.0, 0.0,self.view.frame.size.width, self.view.frame.size.height - rect.size.height);
}

- (void) keyboardDidHide:(NSNotification*)nc
{
    backgroudView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
}
- (void)  didClientLoginFaild:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [WizGlobals reportError:error];
    self.checkToolApi = nil;
}
- (void) didClientLoginSucceed:(NSString *)accountUserId retObject:(id)ret
{
    [[WizAccountManager defaultManager] updateAccount:self.userName password:self.password];
    [[WizAccountManager defaultManager] registerActiveAccount:self.userName];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) clientLogin
{
    [passwordTextField resignFirstResponder];
    [usernameTextField resignFirstResponder];
    //
    self.password = passwordTextField.text;
    self.userName = [usernameTextField.text lowercaseString];
    //
    NSString* error = WizStrError;
    if (self.password == nil|| [self.password length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:WizStrPleaseenterpassword delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if (self.userName == nil || [self.userName length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:WizStrPleaseenteuserid  delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
    if (self.checkToolApi == nil || self.checkToolApi.statue == WizApiStatueNormal) {
        self.checkToolApi = [[[WizApiClientLogin alloc] init] autorelease];
        self.checkToolApi.password = self.password;
        self.checkToolApi.accountUserId = self.userName;
        self.checkToolApi.delegate = self;
        [self.checkToolApi start];
        MBProgressHUD* hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hub.labelText = NSLocalizedString(@"Login.....", nil);
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    WGNavigationBar* navBar = [[[WGNavigationBar alloc] init] autorelease];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor blackColor],
                                UITextAttributeTextColor,
                                [UIColor clearColor],
                                UITextAttributeTextShadowColor, nil];
    [navBar setTitleTextAttributes:attributes];
    [self.navigationController setValue:navBar forKeyPath:@"navigationBar"];
    
    //
    backgroudView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
    backgroudView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:backgroudView];
    //
    float startX = 10;
    float width = self.view.frame.size.width - 20;
    usernameTextField.frame = CGRectMake(0.0, 0.0, width, 40);
    passwordTextField.frame = CGRectMake(0.0, 40, width, 40);
    //
    
    UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 39.5, width, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [inputBackgroudView addSubview:lineView];
    [lineView release];
    [inputBackgroudView addSubview:usernameTextField];
    [inputBackgroudView addSubview:passwordTextField];
    //
    inputBackgroudView.frame = CGRectMake(startX, 40, width, 80);
    [backgroudView addSubview:inputBackgroudView];
    
    clientLoginButton.frame = CGRectMake(startX, 140, width, 40);
    [clientLoginButton setBackgroundImage:[UIImage imageNamed:@"loginButtonBackgroud"] forState:UIControlStateNormal];
    clientLoginButton.titleLabel.textColor = [UIColor whiteColor];
    [backgroudView addSubview:clientLoginButton];
    //
    UIBarButtonItem* backItem = [WGBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"loginBackArrow"] hightedImage:nil target:self selector:@selector(backToHome)];
    self.navigationItem.leftBarButtonItem = backItem;
	// Do any additional setup after loading the view.
}
- (void) backToHome
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // test if our control subview is on-screen
    if (clientLoginButton.superview != nil) {
        if ([touch.view isDescendantOfView:clientLoginButton]) {
            // we touched our control surface
            return NO; // ignore the touch
        }
    }
    return YES; // handle the touch
}

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
