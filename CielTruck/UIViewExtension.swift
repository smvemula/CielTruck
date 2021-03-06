//
//  UIViewExtension.swift
//  PlayNFLBetting
//
//  Created by Vemula, Manoj (Contractor) on 4/2/15.
//  Copyright (c) 2015 Vemula, Manoj (Contractor). All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

extension UIView {
    public func startLoading(){
        self.startLoading(UIActivityIndicatorViewStyle.WhiteLarge, alpha: 1, message: "", fontSize: 17.0)
    }
    
    public func startLoadingWithText(message: String) {
        self.startLoading(UIActivityIndicatorViewStyle.WhiteLarge, alpha: 1, message: message, fontSize: 17.0)
    }
    
    public func startLoadingWithText(message: String, fontSize: CGFloat) {
        self.startLoading(UIActivityIndicatorViewStyle.WhiteLarge, alpha: 1, message: message, fontSize: fontSize)
    }
    
    //Used for cancelling the tune API call
    func canceltask() {
        /*if let taskRunning = MyNetwork.instance().task {
            if taskRunning.state == .Running {
                taskRunning.cancel()
            }
        }*/
        self.stopLoading()
    }
    
    public func addPulseEffect() {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 1
        pulseAnimation.fromValue = 0.7
        pulseAnimation.toValue = 1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = FLT_MAX
        self.layer.addAnimation(pulseAnimation, forKey: nil)
    }
    
    public func stopPulseEffect() {
        self.layer.removeAllAnimations()
    }
    
    public func startLoading(indicatorStyle: UIActivityIndicatorViewStyle, alpha:CGFloat, message: String, fontSize: CGFloat){
        
        self.stopLoading()
        dispatch_async(dispatch_get_main_queue(), {let loadingView = UIView(frame: self.bounds)
            loadingView.backgroundColor = UIColor.pinkCielColor.colorWithAlphaComponent(alpha)
            loadingView.tag = 9999
            
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: indicatorStyle)
            indicator.startAnimating()
            indicator.color = UIColor.brownCielColor
            indicator.center = loadingView.center
            
            
            if message.utf16.count > 0 {
                loadingView.frame = CGRectMake(0, 0, self.bounds.size.width, 50)
                let label = UILabel(frame: CGRectMake(15, 5, loadingView.frame.size.width - 80, 40))
                label.numberOfLines = 2
                label.textColor = UIColor.brownCielColor
                label.textAlignment = NSTextAlignment.Left
                label.text = message
                indicator.frame = CGRectMake(loadingView.frame.size.width - 50, 10, 30, 30)
                loadingView.addSubview(label)
            }
            
            loadingView.addSubview(indicator)
            
            
            
            if(!self.isLoading){
                self.addSubview(loadingView)
            }
        })
    }
    
    func drawBorder() {
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.colorWithHexString("#663300", andAlpha: 0.5).CGColor
    }
    
    public var isLoading: Bool{
        get{
            for view in self.subviews {
                if view.tag == 9999{
                    return true
                }
            }
            return false
        }
    }
    
    public func stopLoading(){
        
        var foundView:UIView?
        for view in self.subviews {
            if view.tag == 9999{
                foundView = view
            }
        }
        if let view = foundView{
            dispatch_async(dispatch_get_main_queue(), {
                view.removeFromSuperview()
            })
        }
        
    }
}