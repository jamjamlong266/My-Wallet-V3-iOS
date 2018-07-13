//
//  Settings+Helpers.swift
//  Blockchain
//
//  Created by Justin on 7/10/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension SettingsTableViewController {
    
    func getAllCurrencySymbols() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didGetCurrencySymbols),
                                               name: NSNotification.Name(rawValue: "GetAllCurrencySymbols"), object: nil)
        WalletManager.sharedInstance().wallet.getBtcExchangeRates()
    }
    
    @objc func didGetCurrencySymbols() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "GetAllCurrencySymbols"), object: nil)
        updateCurrencySymbols()
    }
    
    func getLocalSymbolFromLatestResponse() -> CurrencySymbol? {
        return WalletManager.sharedInstance().latestMultiAddressResponse?.symbol_local
    }
    func getBtcSymbolFromLatestResponse() -> CurrencySymbol? {
        return WalletManager.sharedInstance().latestMultiAddressResponse?.symbol_btc
    }
    func alertUserOfErrorLoadingSettings() {
        let title = "\(LocalizationConstants.Errors.error) \(LocalizationConstants.Errors.loadingSettings)"
        let alertForErrorLoading = UIAlertController(title: title, message: LocalizationConstants.Errors.checkConnection, preferredStyle: .alert)
        alertForErrorLoading.addAction(UIAlertAction(title: LocalizationConstants.okString, style: .cancel, handler: nil))
        present(alertForErrorLoading, animated: true)
        UserDefaults.standard.set(0, forKey: "loadedSettings")
    }
    func alertUserOfSuccess(_ successMessage: String?) {
        let alertForSuccess = UIAlertController(title: LocalizationConstantsObjcBridge.success(), message: successMessage, preferredStyle: .alert)
        alertForSuccess.addAction(UIAlertAction(title: LocalizationConstants.okString, style: .cancel, handler: nil))
        if (alertTargetViewController != nil) {
            alertTargetViewController?.present(alertForSuccess, animated: true)
        } else {
            navigationController?.present(alertForSuccess, animated: true)
        }
        reload()
    }

    func alertUserOfError(_ errorMessage: String?) {
        let alertForError = UIAlertController(title: LocalizationConstants.Errors.error, message: errorMessage, preferredStyle: .alert)
        alertForError.addAction(UIAlertAction(title:LocalizationConstants.okString, style: .cancel, handler: nil))
        if (alertTargetViewController != nil) {
            alertTargetViewController?.present(alertForError, animated: true)
        } else {
            navigationController?.present(alertForError, animated: true)
        }
    }

    func walletIdentifierClicked() {
        let alert = UIAlertController(title: LocalizationConstants.AddressAndKeyImport.copyWalletId,
                                      message: LocalizationConstants.AddressAndKeyImport.copyWarning,
                                      preferredStyle: .actionSheet)
        let copyAction = UIAlertAction(title: LocalizationConstants.AddressAndKeyImport.copyCTA, style: .destructive, handler: { action in
            UIPasteboard.general.string = WalletManager.sharedInstance().wallet.guid
        })
        let cancelAction = UIAlertAction(title: LocalizationConstants.cancel, style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(copyAction)
        present(alert, animated: true)
    }

    func emailClicked() {
        let verifyEmailController = BCVerifyEmailViewController(emailDelegate: delegate)
        navigationController?.pushViewController(verifyEmailController!, animated: true)
    }

    // MARK: - Email Delegate
    func isEmailVerified() -> Bool {
        return WalletManager.sharedInstance().wallet.hasVerifiedEmail()
    }

    func getEmail() -> String? {
        return WalletManager.sharedInstance().wallet.getEmail()
    }

    func prepareForForChangingTwoStep() {
        let enableTwoStepCell: UITableViewCell? = tableView.cellForRow(at: IndexPath(row: securityTwoStep, section: sectionSecurity))
        enableTwoStepCell?.isUserInteractionEnabled = false
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.changeTwoStepSuccess),
                                               name: NSNotification.Name(rawValue: "ChangeTwoStep"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.changeTwoStepError), name:
            NSNotification.Name(rawValue: "ChangeTwoStepError"),
                                               object: nil)
    }
    func doneChangingTwoStep() {
        let enableTwoStepCell: UITableViewCell? = tableView.cellForRow(at: IndexPath(row: securityTwoStep, section: sectionSecurity))
        enableTwoStepCell?.isUserInteractionEnabled = true
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ChangeTwoStep"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ChangeTwoStepError"), object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.numberDelegate = self
        self.delegate = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.register(SettingsToggleTableViewCell.self, forCellReuseIdentifier: "settingsToggle")
        self.tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: "settingsCell")
        UserDefaults.standard.set(1, forKey: "loadedSettings")
        updateEmailAndMobileStrings()
        reload()
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: NSNotification.Name(rawValue: "reloadSettings"), object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.reloadAfterMultiAddressResponse),
                                               name: NSNotification.Name(rawValue: "reloadSettingsAfterMultiAddress"),
                                               object: nil)
    }
}

extension AppSettingsController {
    // MARK: -getUserEmail
    func getUserEmail() -> String? {
        return WalletManager.sharedInstance().wallet.getEmail()
    }
    
    // MARK: -formatDetailCell
    func formatDetailCell(_ verified: Bool, _ cell: UITableViewCell) {
        if verified {
            cell.detailTextLabel?.text = LocalizationConstants.verified
            cell.detailTextLabel?.textColor = Constants.Colors.ColorGreenPrimary
        } else {
            cell.detailTextLabel?.text = LocalizationConstants.unverified
            cell.detailTextLabel?.textColor = Constants.Colors.ColorRedPrimary
        }
    }
    
    // MARK: -isMobileVerified
    func isMobileVerified() -> Bool {
        return WalletManager.sharedInstance().wallet.hasVerifiedMobileNumber()
    }
    
    // MARK: -getMobileNumber
    func getMobileNumber() -> String? {
        return WalletManager.sharedInstance().wallet.getSMSNumber()
    }
}

extension CustomSettingCell {
    func styleCell() {
        title?.textColor = .black
        title?.font = UIFont(name: Constants.FontNames.montserratLight, size: Constants.FontSizes.MediumLarge)
    }
}

extension CustomDetailCell {
    func formatDetails() {
        subtitle?.font = UIFont(name: Constants.FontNames.montserratLight, size: Constants.FontSizes.Small)
    }
    func mockCell() {
        // Only for Interface Builder
        subtitle?.text = LocalizationConstants.more
        subtitle?.textColor = Constants.Colors.ColorRedPrimary
    }
}
