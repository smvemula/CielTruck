//
//  SecondViewController.swift
//  CielTruck
//
//  Created by Vemula, Manoj (Contractor) on 5/15/15.
//  Copyright (c) 2015 Vemula, Manoj (Contractor). All rights reserved.
//

import UIKit
import Firebase

class SecondViewController: UIViewController, UITableViewDelegate {
    
    var menu = [NSDictionary]()
    var itemsDict : [String: NSDictionary] = Dictionary()
    @IBOutlet var menuTable : UITableView!
    var ref : Firebase!
    
    var isAdmin = false

    func orderSummary() -> String {
        var temp = ""
        for (index,each) in EnumerateSequence(self.selectedItems) {
            if temp.utf16.count > 0 {
                temp = "\(temp) \n\(index+1). \(each)"
            } else {
                temp = "\n\(index+1). \(each)"
            }
        }
        return temp
    }
    var isOrdering = false
    
    var selectedItems = [String]()
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    func showOrders() {
        self.performSegueWithIdentifier("showMyOrders", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? OrdersVC {
            //vc.myOrders = self.ordersDict.allValues as! [NSDictionary]
        }
    }
    
    var ordersDict = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        ref = Firebase(url:"https://cieldessertbar.firebaseio.com/Menu")
        self.getAllDataForMenu()
        self.navigationController?.navigationBar.barTintColor = UIColor.darkPinkCielColor
        self.view.backgroundColor = UIColor.cielBackgroundColor
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startOrdering", name: "order", object: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Order", style: UIBarButtonItemStyle.Plain, target: self, action: "startOrdering")
        if isAdmin {
            Firebase(url:"https://cieldessertbar.firebaseio.com/Orders").observeEventType(.Value, withBlock: { snapshot -> Void in
                print("Current User orders are \(snapshot)")
                if let value = snapshot.value as? NSDictionary {
                    self.ordersDict = value
                    self.addMyOrdersButton()
                }
            })
        } else {
            Firebase(url:"https://cieldessertbar.firebaseio.com/Orders").queryOrderedByChild("id").queryEqualToValue(UIDevice.currentDevice().identifierForVendor!.UUIDString).observeEventType(.Value, withBlock: { snapshot -> Void in
                print("Current User orders are \(snapshot)")
                if let value = snapshot.value as? NSDictionary {
                    self.ordersDict = value
                    self.addMyOrdersButton()
                }
            })
        }
    }
    
    func addMyOrdersButton() {
        var count = 0
        for each in self.ordersDict.allValues {
            if let statusString = each["status"] as? String {
                if statusString != "DONE" {
                    count++
                }
            }
        }
        let view = UIView(frame: CGRect(x: 0, y: 10, width: 100, height: 40))
        let label1 = UILabel(frame: CGRect(x: -5, y: 0, width: 20, height: 20))
        label1.text = "\(count)"
        label1.backgroundColor = UIColor.brownCielColor
        label1.textAlignment = NSTextAlignment.Center
        label1.layer.cornerRadius = 10
        label1.layer.masksToBounds = true
        label1.textColor = UIColor.whiteColor()
        if count > 0 {
            view.addSubview(label1)
        }
        let label = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        label.setTitle("My Orders", forState: UIControlState.Normal)
        label.addTarget(self, action: "showOrders", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(label)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: view)
    }
    
    func startOrdering() {
        self.isOrdering = true
        self.selectedItems = []
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelOrder")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Order(0)", style: UIBarButtonItemStyle.Plain, target: self, action: "goAheadOrder")
        self.menuTable.reloadData()
    }
    
    func cancelOrder() {
        if self.selectedItems.count > 0 {
            let order = UIAlertController(title: "Cancel Order", message: "Would you like to cancel this order \(self.orderSummary()) ?", preferredStyle: UIAlertControllerStyle.Alert)
            order.view.tintColor = UIColor.darkPinkCielColor
            let cancelOrder = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive, handler: { action in
                self.resetValues()
            })
            order.addAction(cancelOrder)
            let nothing = UIAlertAction(title: "NO", style: UIAlertActionStyle.Cancel, handler: { action in
            })
            order.addAction(nothing)
            self.presentViewController(order, animated: true, completion: {
                order.view.tintColor = UIColor.darkPinkCielColor
            })
        } else {
            self.resetValues()
        }
    }
    
    func resetValues() {
        self.isOrdering = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Order", style: UIBarButtonItemStyle.Plain, target: self, action: "startOrdering")
        self.selectedItems = []
        self.addMyOrdersButton()
        self.menuTable.reloadData()
    }
    
    func goAheadOrder() {
        if self.selectedItems.count == 0 {
            UIAlertView.showAlertView("Error", text: "No items selected", vc: self)
        } else {
            let order = UIAlertController(title: "New Ciel Order - Pick up", message: "Placing order for \(self.orderSummary()) items", preferredStyle: UIAlertControllerStyle.Alert)
            order.view.tintColor = UIColor.darkPinkCielColor
            
            order.addTextFieldWithConfigurationHandler({textField in
                textField.placeholder = "Enter Your name"
                textField.autocapitalizationType = UITextAutocapitalizationType.Sentences
                textField.returnKeyType = UIReturnKeyType.Next
                if let exists = NSUserDefaults.standardUserDefaults().objectForKey("User") as? String {
                    textField.text = exists
                }
            })
            order.addTextFieldWithConfigurationHandler({textField in
                textField.placeholder = "Enter Your Phone number"
                textField.keyboardType = UIKeyboardType.PhonePad
                if let exists = NSUserDefaults.standardUserDefaults().objectForKey("Phone") as? String {
                    textField.text = exists
                }
            })
            let doOrder = UIAlertAction(title: "Order", style: UIAlertActionStyle.Default, handler: { action in
                var isError = true
                if let textTyped = order.textFields![0].text {
                    if textTyped.utf16.count > 0 {
                        isError = false
                    }
                }
                if let textTyped = order.textFields![1].text {
                    if textTyped.utf16.count == 10 {
                        isError = isError ? isError : false
                    } else {
                        isError = true
                    }
                }
                if isError {
                    let error = UIAlertController(title: "Error", message: "Name & Valid Phone number are required to complete your order.", preferredStyle: UIAlertControllerStyle.Alert)
                    order.view.tintColor = UIColor.darkPinkCielColor
                    let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { action in
                        self.presentViewController(order, animated: true, completion: {
                            order.view.tintColor = UIColor.darkPinkCielColor
                        })
                    })
                    error.addAction(ok)
                    self.presentViewController(error, animated: true, completion: {
                        error.view.tintColor = UIColor.darkPinkCielColor
                    })
                } else {
                    //Complete Order
                    NSUserDefaults.standardUserDefaults().setObject(order.textFields![0].text!, forKey: "User")
                    NSUserDefaults.standardUserDefaults().setObject(order.textFields![1].text!, forKey: "Phone")
                    Firebase(url:"https://cieldessertbar.firebaseio.com/Orders").childByAutoId().setValue(["timestamp": FirebaseServerValue.timestamp(), "name": order.textFields![0].text!, "phone": order.textFields![1].text!, "order": self.orderSummary().stringByReplacingOccurrencesOfString("\n", withString: ""), "id": UIDevice.currentDevice().identifierForVendor!.UUIDString, "status": "NEW"])
                    UIAlertView.showAlertView("Success", text: "Placed order for \(self.orderSummary()) items. Thank you \(order.textFields![0].text!)", vc: self)
                    self.resetValues()
                }
            })
            order.addAction(doOrder)
            let nothing = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in
            })
            order.addAction(nothing)
            self.presentViewController(order, animated: true, completion: {
                order.view.tintColor = UIColor.darkPinkCielColor
            })
        }
    }
    
    func getAllDataForMenu() {
        self.view.startLoading()
  
        ref.observeEventType(.Value, withBlock: { snapshot in
            //print("Inial Value \(snapshot.value)")
            if let menuDict = snapshot.value as? NSDictionary {
                self.menu = [NSDictionary]()
                self.itemsDict = Dictionary()
                let keys = menuDict.allKeys as! [String]
                for key in keys {
                    if let menuValue = menuDict[key] as? NSDictionary {
                        if let extra = menuValue["extra"] as? String {
                            self.menu.append(["name": key, "extra": extra])
                        }
                        if let sub = menuValue["subMenu"] as? NSDictionary {
                            self.itemsDict[key] = sub
                        }
                    }
                    
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.menuTable.reloadData()
                self.view.stopLoading()
            })
            
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    func getRandomColor() -> UIColor{
        
        let randomRed:CGFloat = CGFloat(drand48())
        
        let randomGreen:CGFloat = CGFloat(drand48())
        
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

//MARK: TableViewDelegate & Datasource Methods
extension SecondViewController {
    //TableView Row Methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell
        
        if let reuseCell = tableView.dequeueReusableCellWithIdentifier("CELL")  {
            cell = reuseCell
        } else {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "CELL")
        }
        
        cell.textLabel?.textColor = UIColor.brownCielColor
        cell.textLabel?.highlightedTextColor = UIColor.darkPinkCielColor
        cell.textLabel?.font = UIFont.boldSystemFontOfSize(15)
        cell.detailTextLabel?.textColor = UIColor.brownCielColor
        cell.detailTextLabel?.highlightedTextColor = UIColor.darkPinkCielColor
        
        let key = self.menu[indexPath.section]["name"] as! String
        if let item = self.itemsDict[key] {
            let keys = item.allKeys as! [String]
            if let object = item[keys[indexPath.row]] as? NSDictionary {
                cell.textLabel?.text = keys[indexPath.row]
                if self.isOrdering {
                    cell.accessoryView = UIImageView(image: UIImage(named: "checkMark")?.tintWithColor(UIColor.lightGrayColor()), highlightedImage: UIImage(named: "checkMark")?.tintWithColor(UIColor.darkPinkCielColor))
                    if self.selectedItems.contains("\(keys[indexPath.row])(\(key))") {
                        cell.setSelected(true, animated: false)
                    } else {
                        cell.setSelected(false, animated: false)
                    }
                } else{
                    cell.accessoryView = nil
                }
                cell.detailTextLabel?.text = ""
                if let price = object["price"] as? Int {
                    if price > 0 {
                        cell.detailTextLabel?.text = "Rs. \(price)"
                    }
                }
            }
            
            var imageName = ""
            switch key {
            case "Brownies":
                imageName = "brownie"
            case "Cookies":
                imageName = "cookies1"
            case "Choux Pastry":
                imageName = "pastry2"
            case "Desserts":
                imageName = "dessert"
            case "Loafs":
                imageName = "loafs"
            case "Lamingtons":
                imageName = "pastry1"
            case "Muffins":
                imageName = "muffin1"
            case "Pastries":
                imageName = "pastry5"
            default:
                imageName = "cupcake"
            }
            
            cell.imageView?.image = UIImage(named: imageName)?.tintWithColor(self.getRandomColor())
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if isOrdering {
            let key = self.menu[indexPath.section]["name"] as! String
            if let item = self.itemsDict[key] {
                let keys = item.allKeys as! [String]
                self.selectedItems.append("\(keys[indexPath.row])(\(key))")
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Order(\(self.selectedItems.count))", style: UIBarButtonItemStyle.Plain, target: self, action: "goAheadOrder")
            }
        } else {
            self.menuTable.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let key = self.menu[indexPath.section]["name"] as! String
        if let item = self.itemsDict[key] {
            let keys = item.allKeys as! [String]
            self.selectedItems.removeObject(&self.selectedItems, object: "\(keys[indexPath.row])(\(key))")
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Order(\(self.selectedItems.count))", style: UIBarButtonItemStyle.Plain, target: self, action: "goAheadOrder")
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let key = self.menu[section]["name"] as? String {
            if let items = self.itemsDict[key] {
                return items.allKeys.count
            }
        }
        return 0
    }
    //TableView Section Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.menu.count
    }
    //TableView Footer Methods
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView = UIView(frame: CGRectMake(0,0, self.menuTable.frame.size.width, 40))
        let sectionTitle = UILabel(frame: CGRectMake(15,0, self.menuTable.frame.size.width/2 - 15, 40))
        if let name = self.menu[section]["name"] as? String {
            sectionTitle.text = name
        }
        sectionTitle.textAlignment = NSTextAlignment.Left
        sectionTitle.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.1)
        sectionTitle.textColor = UIColor.brownCielColor
        sectionTitle.font = UIFont.systemFontOfSize(15)
        sectionView.addSubview(sectionTitle)
        
        let detailTitle = UILabel(frame: CGRectMake(self.menuTable.frame.size.width/2,0, self.menuTable.frame.size.width/2 - 15, 40))
        if let extra = self.menu[section]["extra"] as? String {
            detailTitle.text = extra
        }
        detailTitle.textAlignment = NSTextAlignment.Right
        detailTitle.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.1)
        detailTitle.textColor = UIColor.brownCielColor
        detailTitle.font = UIFont.systemFontOfSize(12)
        sectionView.addSubview(detailTitle)
        
        sectionView.backgroundColor = UIColor.pinkCielColor
        
        return sectionView
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
}
