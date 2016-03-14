//
//  AccountsAndAddressesNavigationController.m
//  Blockchain
//
//  Created by Kevin Wu on 1/12/16.
//  Copyright © 2016 Qkos Services Ltd. All rights reserved.
//

#import "AccountsAndAddressesNavigationController.h"
#import "AccountsAndAddressesViewController.h"
#import "AccountsAndAddressesDetailViewController.h"
#import "AppDelegate.h"
#import "PrivateKeyReader.h"
#import "SendViewController.h"

@interface AccountsAndAddressesNavigationController ()

@end

@implementation AccountsAndAddressesNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.frame = CGRectMake(0, 0, app.window.frame.size.width, app.window.frame.size.height);
    
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, DEFAULT_HEADER_HEIGHT)];
    topBar.backgroundColor = COLOR_BLOCKCHAIN_BLUE;
    [self.view addSubview:topBar];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 17.5, self.view.frame.size.width - 160, 40)];
    headerLabel.font = [UIFont systemFontOfSize:22.0];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.adjustsFontSizeToFitWidth = YES;
    headerLabel.text = BC_STRING_ADDRESSES;
    [topBar addSubview:headerLabel];
    self.headerLabel = headerLabel;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    backButton.contentEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
    [backButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [backButton setImage:[UIImage imageNamed:@"back_chevron_icon"] forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor colorWithWhite:0.56 alpha:1.0] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:backButton];
    self.backButton = backButton;
    
    BCFadeView *busyView = [[BCFadeView alloc] initWithFrame:app.window.rootViewController.view.frame];
    busyView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    UIView *textWithSpinnerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 110)];
    textWithSpinnerView.backgroundColor = [UIColor whiteColor];
    [busyView addSubview:textWithSpinnerView];
    textWithSpinnerView.center = busyView.center;
    
    self.busyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 230, 30)];
    self.busyLabel.font = [UIFont systemFontOfSize:14.0];
    self.busyLabel.alpha = 0.75;
    self.busyLabel.textAlignment = NSTextAlignmentCenter;
    self.busyLabel.adjustsFontSizeToFitWidth = YES;
    self.busyLabel.text = BC_STRING_LOADING_SYNCING_WALLET;
    self.busyLabel.center = CGPointMake(textWithSpinnerView.bounds.origin.x + textWithSpinnerView.bounds.size.width/2, textWithSpinnerView.bounds.origin.y + textWithSpinnerView.bounds.size.height/2 + 15);
    [textWithSpinnerView addSubview:self.busyLabel];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(textWithSpinnerView.bounds.origin.x + textWithSpinnerView.bounds.size.width/2, textWithSpinnerView.bounds.origin.y + textWithSpinnerView.bounds.size.height/2 - 15);
    [textWithSpinnerView addSubview:spinner];
    [textWithSpinnerView bringSubviewToFront:spinner];
    [spinner startAnimating];
    
    busyView.containerView = textWithSpinnerView;
    [busyView fadeOut];
    
    [self.view addSubview:busyView];
    
    [self.view bringSubviewToFront:busyView];
    
    self.busyView = busyView;
}

- (void)showBusyViewWithLoadingText:(NSString *)text
{
    self.busyLabel.text = text;
    [self.view bringSubviewToFront:self.busyView];
    if (self.busyView.alpha < 1.0) {
        [self.busyView fadeIn];
    }
}

- (void)updateBusyViewLoadingText:(NSString *)text
{
    if (self.busyView.alpha == 1.0) {
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            [self.busyLabel setText:text];
        }];
    }
}

- (void)hideBusyView
{
    if (self.busyView.alpha == 1.0) {
        [self.busyView fadeOut];
    }
}

- (void)presentAlertController:(UIAlertController *)alertController
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ANIMATION_DURATION_LONG * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.presentedViewController) {
            [self.presentedViewController presentViewController:alertController animated:YES completion:nil];
        } else {
            [self presentViewController:alertController animated:YES completion:nil];
        }
    });
}

- (void)reload
{
    if (![self.visibleViewController isMemberOfClass:[AccountsAndAddressesViewController class]] &&
        ![self.visibleViewController isMemberOfClass:[AccountsAndAddressesDetailViewController class]]) {
        [self popViewControllerAnimated:YES];
    }
    
    if (!self.view.window) {
        [self popToRootViewControllerAnimated:NO];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_RELOAD_ACCOUNTS_AND_ADDRESSES object:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (self.viewControllers.count == 1 || [self.visibleViewController isMemberOfClass:[AccountsAndAddressesViewController class]]) {
        self.backButton.frame = CGRectMake(self.view.frame.size.width - 80, 15, 80, 51);
        self.backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        self.backButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self.backButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)];
        [self.backButton setTitle:BC_STRING_CLOSE forState:UIControlStateNormal];
        [self.backButton setImage:nil forState:UIControlStateNormal];
    } else {
        self.backButton.frame = CGRectMake(0, 12, 85, 51);
        self.backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.backButton setTitle:@"" forState:UIControlStateNormal];
        [self.backButton setImage:[UIImage imageNamed:@"back_chevron_icon"] forState:UIControlStateNormal];
    }
}

- (void)alertUserToTransferAllFunds
{
    UIAlertController *alertToTransfer = [UIAlertController alertControllerWithTitle:BC_STRING_TRANSFER_FUNDS message:[NSString stringWithFormat:@"%@\n\n%@", BC_STRING_TRANSFER_FUNDS_DESCRIPTION_ONE, BC_STRING_TRANSFER_FUNDS_DESCRIPTION_TWO] preferredStyle:UIAlertControllerStyleAlert];
    [alertToTransfer addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:nil]];
    [alertToTransfer addAction:[UIAlertAction actionWithTitle:BC_STRING_TRANSFER_FUNDS style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self transferAllFundsClicked];
    }]];
    [alertToTransfer addAction:[UIAlertAction actionWithTitle:BC_STRING_DONT_SHOW_AGAIN style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USER_DEFAULTS_KEY_HIDE_TRANSFER_ALL_FUNDS_ALERT];
    }]];
    
    [self presentViewController:alertToTransfer animated:YES completion:nil];
}

- (void)transferAllFundsClicked
{
    [self dismissViewControllerAnimated:YES completion:^{
        [app closeSideMenu];
    }];
    
    if (!app.sendViewController) {
        app.sendViewController = [[SendViewController alloc] initWithNibName:NIB_NAME_SEND_COINS bundle:[NSBundle mainBundle]];
    }
    
    
    [app showSendCoins];
    
    [app.sendViewController transferFundsFromAddress:@""];
}

- (IBAction)backButtonClicked:(UIButton *)sender
{
    if ([self.visibleViewController isMemberOfClass:[AccountsAndAddressesViewController class]]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        app.topViewControllerDelegate = nil;
    } else {
        [self popViewControllerAnimated:YES];
    }
}

- (void)didGenerateNewAddress
{
    if ([self.visibleViewController isMemberOfClass:[AccountsAndAddressesViewController class]]) {
        AccountsAndAddressesViewController *accountsAndAddressesViewController = (AccountsAndAddressesViewController *)self.visibleViewController;
        [accountsAndAddressesViewController didGenerateNewAddress];
    }
}

@end
