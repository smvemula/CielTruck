//
//  OrdersVC.swift
//  CielTruck
//
//  Created by Vemula, Manoj (Contractor) on 12/9/15.
//  Copyright © 2015 Vemula, Manoj (Contractor). All rights reserved.
//

import UIKit
import Firebase

class OrdersVC: UIViewController {
    
    var myOrders = [NSDictionary]()
    @IBOutlet var ordersTable : UITableView!
    
    var adminDict = NSDictionary()
    var isAdmin = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "My Orders"
        if isAdmin {
            Firebase(url:"https://cieldessertbar.firebaseio.com/Orders").observeEventType(.Value, withBlock: { snapshot -> Void in
                print("Current User orders are \(snapshot)")
                if let value = snapshot.value as? NSDictionary {
                    self.adminDict = value
                    self.myOrders = value.allValues as! [NSDictionary]
                    self.myOrders = self.myOrders.sort{return $0["timestamp"] as! Double >  $1["timestamp"] as! Double}
                    self.ordersTable.reloadData()
                }
            })
        } else {
            Firebase(url:"https://cieldessertbar.firebaseio.com/Orders").queryOrderedByChild("id").queryEqualToValue(UIDevice.currentDevice().identifierForVendor!.UUIDString).observeEventType(.Value, withBlock: { snapshot -> Void in
                print("Current User orders are \(snapshot)")
                if let value = snapshot.value as? NSDictionary {
                    self.myOrders = value.allValues as! [NSDictionary]
                    self.myOrders = self.myOrders.sort{return $0["timestamp"] as! Double >  $1["timestamp"] as! Double}
                    self.ordersTable.reloadData()
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

//MARK: TableViewDelegate & Datasource Methods
extension OrdersVC {
    //TableView Row Methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell
        
        if let reuseCell = tableView.dequeueReusableCellWithIdentifier("CELL")  {
            cell = reuseCell
        } else {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "CELL")
            cell.selectionStyle = UITableViewCellSelectionStyle.None
        }
        
        cell.textLabel?.textColor = UIColor.brownCielColor
        cell.textLabel?.highlightedTextColor = UIColor.darkPinkCielColor
        cell.textLabel?.font = UIFont.boldSystemFontOfSize(15)
        cell.detailTextLabel?.textColor = UIColor.brownCielColor
        cell.detailTextLabel?.highlightedTextColor = UIColor.darkPinkCielColor
        
        if let order = self.myOrders[indexPath.row]["order"] as? String {
            cell.textLabel?.text = order
        }
        if let date = self.myOrders[indexPath.row]["timestamp"] as? Double {
            let detailed = NSDate.getDefaultTimeUsingGMTDoubleValue(date, dateFormat: "MM/d/yyyy h.mm aa")
            if isAdmin {
                if let phone = self.myOrders[indexPath.row]["phone"] as? String {
                    if let name = self.myOrders[indexPath.row]["name"] as? String {
                        cell.detailTextLabel?.text = "\(name) \(phone) \(detailed)"
                    }
                }
            } else {
                cell.detailTextLabel?.text = detailed
            }
        }
        
        if let statusString = self.myOrders[indexPath.row]["status"] as? String {
            let status = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
            status.text = statusString
            status.textColor = UIColor.darkPinkCielColor
            status.textAlignment = NSTextAlignment.Right
            status.font = UIFont.boldSystemFontOfSize(8)
            cell.accessoryView = status
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        var buttons = [UITableViewRowAction]()
        if let statusString = self.myOrders[indexPath.row]["status"] as? String {
            let button = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: statusString == "MAKING" ? "DONE" : "MAKING") { (action, indexPath) -> Void in
                let keys = self.adminDict.allKeys as!  [String]
                let key = keys[indexPath.row]
                Firebase(url:"https://cieldessertbar.firebaseio.com/Orders/\(key)/status").setValue(statusString == "MAKING" ? "DONE" : "MAKING")
            }
            button.backgroundColor = UIColor.darkPinkCielColor
            if statusString != "DONE" {
                buttons.append(button)
            }
        }
        if let phone = self.myOrders[indexPath.row]["phone"] as? String {
            let button1 = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Call") { (action, indexPath) -> Void in
                UIApplication.sharedApplication().openURL(NSURL(string: "tel://+91\(phone)")!)
            }
            button1.backgroundColor = UIColor.brownCielColor
            buttons.append(button1)
        }
        
        return buttons
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return self.isAdmin
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.ordersTable.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myOrders.count
    }
}
