//
//  SocialConnectViewController.swift
//  CielTruck
//
//  Created by Vemula, Manoj (Contractor) on 5/15/15.
//  Copyright (c) 2015 Vemula, Manoj (Contractor). All rights reserved.
//

import UIKit

class SocialConnectViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet var web : UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.startLoading()
        let url = NSURL(string: "https://m.facebook.com/profile.php?id=785910588168359&tsid=0.48038841295056045&source=typeahead")
        let request = NSURLRequest(URL: url!)
        self.web.delegate = self
        self.web.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        dispatch_async(dispatch_get_main_queue(), {
            self.view.stopLoading()
        })
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
