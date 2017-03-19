//
//  Alerst.swift
//  MobIos
//
//  Created by  on 22/01/2015.
//  Copyright (c) 2015 michail fragkiskos. All rights reserved.
//
import Foundation
import UIKit


public class alerts {
    
    var containerView = UIView()
    var progressView = UIView()
    var progressLabel  = UILabel()
    var activityIndicator = UIActivityIndicatorView()
    var timer = NSTimer()
    private var alert: UIAlertController!
    
    public class var shared: alerts {
        struct Static {
            static let instance: alerts = alerts()
        }
        return Static.instance
    }
    
    /*
    * Simple Activity indicator
    */
    
    public func showProgress(view: UIView) {
        
        containerView.frame                          = view.frame
        containerView.center                         = view.center
        containerView.backgroundColor                = UIColor(hex: 0xffffff, alpha: 0.3)
        progressView.frame                           = CGRectMake(0, 0, 150, 100)
        progressView.center                          = view.center
        progressView.backgroundColor                 = UIColor(hex: 0x444444, alpha: 0.7)
        progressView.clipsToBounds                   = true
        progressView.layer.cornerRadius              = 10
        activityIndicator.frame                      = CGRectMake(0, 0, 150, 100)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.center = CGPointMake(progressView.bounds.width / 2, progressView.bounds.height / 2.33)
        progressView.addSubview(activityIndicator)
        
        
        progressLabel               = UILabel(frame: CGRectMake(0, 30, 145, 100))
        progressLabel.textColor     = .whiteColor()
        progressLabel.textAlignment = .Center
        progressLabel.text          = "Please Wait."
        progressLabel.numberOfLines = 0
        progressLabel.tag           = 1
        progressLabel.font          = UIFont(name: "Helvetica Neue", size: 11.0)
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressView.addSubview(progressLabel)
        
        containerView.addSubview(progressView)
        view.addSubview(containerView)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        activityIndicator.startAnimating()
     //  timer = NSTimer.scheduledTimerWithTimeInterval(0.02, target:self, selector: Selector("updateCounter"), userInfo: nil, repeats: true)
    }
    
    /*
    * Alert a costum Messages and buttons
    */
    
    public func ShowAlert(message:String, Okaction:UIAlertAction = UIAlertAction(title: StaticFileds.ok_msg, style: UIAlertActionStyle.Default, handler:nil), Canselaction:UIAlertAction = UIAlertAction(title: StaticFileds.cancel_msg, style: UIAlertActionStyle.Default, handler:nil) , title:String="\(StaticFileds.alert_mobile_msg)"){
        
            
        self.alert=nil
        
       
       let titletxt = NSAttributedString(string: title, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(22), NSForegroundColorAttributeName : UIColor.whiteColor()])
       let messagetxt = NSAttributedString(string: message, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(18), NSForegroundColorAttributeName : UIColor.whiteColor()])
             self.alert = UIAlertController(title:"\(title)", message:"\(message)", preferredStyle: .Alert)
            
           self.alert.setValue(titletxt, forKey: "attributedTitle")
           self.alert.setValue(messagetxt, forKey: "attributedMessage")
            
        let subview = self.alert.view.subviews.first! as UIView
        let alertContent = subview.subviews.first! as UIView
            alertContent.backgroundColor = AppDelegate.colorWithHexString("FF6600")
            alertContent.layer.cornerRadius = 10
            alertContent.alpha = 1
            alertContent.layer.borderWidth = 1
            alertContent.layer.borderColor = UIColor.whiteColor().CGColor
     
            self.alert.addAction(Okaction)

            self.alert.addAction(Canselaction)
        //}
    let rootVC = UIApplication.sharedApplication().keyWindow?.rootViewController
      
    dispatch_async(dispatch_get_main_queue(), {
         rootVC?.presentViewController(self.alert, animated: true, completion: nil)
           self.alert.view.tintColor = UIColor.whiteColor()
        })
         
    }
    
    
    public func hideProgressView() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        activityIndicator.stopAnimating()
         progressLabel.text = ""
        progressView.removeFromSuperview()
        containerView.removeFromSuperview()
        
    }
    
    

}

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat) {
        let red = CGFloat((hex & 0xFF0000) >> 16)/256.0
        let green = CGFloat((hex & 0xFF00) >> 8)/256.0
        let blue = CGFloat(hex & 0xFF)/256.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

