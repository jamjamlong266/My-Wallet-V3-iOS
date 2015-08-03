//
//  BackupWordsViewController.swift
//  Blockchain
//
//  Created by Sjors Provoost on 19-05-15.
//  Copyright (c) 2015 Qkos Services Ltd. All rights reserved.
//

import UIKit

class BackupWordsViewController: UIViewController, SecondPasswordDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var wordsScrollView: UIScrollView?
    @IBOutlet weak var wordsPageControl: UIPageControl?
    @IBOutlet weak var wordsProgressLabel: UILabel?
    @IBOutlet weak var wordLabel: UILabel?
    @IBOutlet weak var screenShotWarningLabel: UILabel?
    @IBOutlet weak var previousWordButton: UIButton!
    @IBOutlet weak var nextWordButton: UIButton!
    @IBOutlet var summaryLabel: UILabel?

    var wallet : Wallet?
    var wordLabels: [UILabel]?
    var isVerifying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let greyText = NSAttributedString(string: NSLocalizedString("(e.g., with your passport)", comment:""), attributes:
            [NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        let blackText = NSAttributedString(string:  NSLocalizedString("Write the words down on a sheet of paper in the exact order they appear on a sheet of paper, and store it somewhere safe\n", comment:""), attributes:
            [NSForegroundColorAttributeName: UIColor.blackColor()])
        
        var finalText = NSMutableAttributedString(attributedString: blackText)
        finalText.appendAttributedString(greyText);
        summaryLabel?.attributedText = finalText
        
        wallet!.addObserver(self, forKeyPath: "recoveryPhrase", options: .New, context: nil)
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()

        if wallet!.needsSecondPassword(){
            self.performSegueWithIdentifier("secondPasswordForBackup", sender: self)
        } else {
            wallet!.getRecoveryPhrase(nil)
        }
        
        wordLabel!.text = ""
        
        updateCurrentPageLabel(0)
        
        wordsScrollView!.clipsToBounds = true
        wordsScrollView!.contentSize = CGSizeMake(12 * wordLabel!.frame.width, wordLabel!.frame.height)
        wordsScrollView!.userInteractionEnabled = false

        wordLabels = [UILabel]()
        wordLabels?.insert(wordLabel!, atIndex: 0)
        var i: CGFloat = 0
        for i in 1 ..< 12 {
            let offset: CGFloat = CGFloat(i) * wordLabel!.frame.width
            let x: CGFloat = wordLabel!.frame.origin.x + offset
            let label = UILabel(frame: CGRectMake(x, wordLabel!.frame.origin.y, wordLabel!.frame.size.width, wordLabel!.frame.size.height))
            label.adjustsFontSizeToFitWidth = true
            label.font = wordLabel!.font
            label.textColor = wordLabel!.textColor
            label.textAlignment = wordLabel!.textAlignment

            wordLabel!.superview?.addSubview(label)
            
            wordLabels?.append(label)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView .animateWithDuration(0.3, animations: { () -> Void in
            self.previousWordButton!.frame.origin = CGPointMake(0,self.view.frame.size.height-self.previousWordButton!.frame.size.height);
            self.nextWordButton!.frame.origin = CGPointMake(self.view.frame.size.width-self.previousWordButton!.frame.size.width, self.view.frame.size.height-self.previousWordButton!.frame.size.height);
        })
    }

    @IBAction func previousWordButtonTapped(sender: UIButton) {
        if (wordsPageControl!.currentPage > 0) {
            let pagePosition = wordLabel!.frame.width * CGFloat(wordsPageControl!.currentPage-1)
            wordsScrollView?.setContentOffset(CGPointMake(pagePosition, wordsScrollView!.contentOffset.y), animated: true)
        }
    }
    
    
    @IBAction func nextWordButtonTapped(sender: UIButton) {
        if let count = wordLabels?.count {
            if (wordsPageControl!.currentPage == count-1) {
                performSegueWithIdentifier("backupVerify", sender: nil)
            } else if wordsPageControl!.currentPage < count-1 {
                var pagePosition = wordLabel!.frame.width * CGFloat(wordsPageControl!.currentPage+1)
                wordsScrollView?.setContentOffset(CGPointMake(pagePosition, wordsScrollView!.contentOffset.y), animated: true)
            }
        }
    }
    
    func updateCurrentPageLabel(page: Int) {
        wordsProgressLabel!.text = NSLocalizedString(NSString(format: "Word %@ of %@", String(page + 1), String(12)) as String, comment: "")
        if let count = wordLabels?.count {
            if wordsPageControl!.currentPage == count-1 {
                nextWordButton?.backgroundColor = Constants.Colors.BlockchainBlue
                nextWordButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                nextWordButton?.setTitle(NSLocalizedString("Done", comment:""), forState: .Normal)
            } else if wordsPageControl!.currentPage == count-2 {
                nextWordButton?.backgroundColor = Constants.Colors.SecondaryGray
                nextWordButton?.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
                nextWordButton?.setTitle(NSLocalizedString("Next Word", comment:""), forState: .Normal)
            }
        }
    }
    
    // MARK: - Words Scrollview
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Determine page number:
        let pageWidth = scrollView.frame.size.width
        let fractionalPage = Float(scrollView.contentOffset.x / pageWidth)
        let page: Int = lroundf(fractionalPage)
        
        wordsPageControl!.currentPage = page
        
        updateCurrentPageLabel(page)
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "secondPasswordForBackup" {
            let vc = segue.destinationViewController as! SecondPasswordViewController
            vc.delegate = self
            vc.wallet = wallet
        } else if segue.identifier == "backupVerify" {
            let vc = segue.destinationViewController as! BackupVerifyViewController
            vc.wallet = wallet
            vc.isVerifying = false
        }
    }
    
    func didGetSecondPassword(password: String) {
        wallet!.getRecoveryPhrase(password)
    }
    
    @IBAction func unwindSecondPasswordSuccess(segue: UIStoryboardSegue) {
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject: AnyObject], context: UnsafeMutablePointer<Void>) {
        let words = wallet!.recoveryPhrase.componentsSeparatedByString(" ")
        for i in 0 ..< 12 {
            wordLabels![i].text = words[i]
        }

    }
    
    deinit {
        wallet!.removeObserver(self, forKeyPath: "recoveryPhrase", context: nil)
    }
}