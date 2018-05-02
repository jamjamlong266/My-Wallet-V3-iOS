//
//  AlertViewPresenter.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc class AlertViewPresenter: NSObject {
    typealias AlertConfirmHandler = ((UIAlertAction) -> Void)

    static let shared = AlertViewPresenter()

    @objc class func sharedInstance() -> AlertViewPresenter { return shared }

    private override init() {
        super.init()
    }

    /// Shows the user an alert that the app failed to read values from the keychain.
    /// Upon confirming on the presented alert, the app will terminate.
    @objc func showKeychainReadError() {
        // TODO
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_FAILED_TO_LOAD_WALLET_TITLE
        // message:BC_STRING_ERROR_LOADING_WALLET_IDENTIFIER_FROM_KEYCHAIN preferredStyle:UIAlertControllerStyleAlert];
//        [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_CLOSE_APP
        // style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//            // Close App
//            UIApplication *app = [UIApplication sharedApplication];
//            [app performSelector:@selector(suspend)];
//            }]];
//
//        [[UIApplication sharedApplication].keyWindow.rootViewController
        //presentViewController:alert animated:YES completion:nil];
    }

    @objc func checkAndWarnOnJailbrokenPhones() {
        guard UIDevice.current.isUnsafe() else {
            return
        }
        AlertViewPresenter.shared.standardNotify(
            message: LocalizationConstants.Errors.warning,
            title: LocalizationConstants.Errors.unsafeDeviceWarningMessage
        )
    }

    @objc func showNoInternetConnectionAlert() {
        standardNotify(
        message: LocalizationConstants.Errors.noInternetConnection,
        title: LocalizationConstants.Errors.error
        ) { _ in
            LoadingViewPresenter.shared.hideBusyView()
            // TODO: this should not be in here. Figure out all areas where pin
            // should be reset and explicitly reset pin entry there
            // [self.pinEntryViewController reset];
        }
    }

    @objc func standardNotify(
        message: String,
        title: String = LocalizationConstants.Errors.error,
        handler: AlertConfirmHandler? = nil
    ) {
        DispatchQueue.main.async {
            guard UIApplication.shared.applicationState == .active else { return }

            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: LocalizationConstants.ok, style: .cancel, handler: handler))

            let window = UIApplication.shared.keyWindow
            guard let topMostViewController = window?.rootViewController?.topMostViewController else {
                window?.rootViewController?.present(alert, animated: true)
                return
            }

            if !(topMostViewController is PEPinEntryController) {
                NotificationCenter.default.addObserver(
                    alert,
                    selector: #selector(UIViewController.autoDismiss),
                    name: NSNotification.Name.UIApplicationDidEnterBackground,
                    object: nil
                )
            }

            topMostViewController.present(alert, animated: true)
        }
    }

}