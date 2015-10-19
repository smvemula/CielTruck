//
//  SecondViewController.swift
//  CielTruck
//
//  Created by Vemula, Manoj (Contractor) on 5/15/15.
//  Copyright (c) 2015 Vemula, Manoj (Contractor). All rights reserved.
//

import UIKit
import Firebase

class SecondViewController: UIViewController {
    
    var menu = [NSDictionary]()
    var itemsDict : [String: NSDictionary] = Dictionary()
    @IBOutlet var menuTable : UITableView!
    var ref : Firebase!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        ref = Firebase(url:"https://cieldessertbar.firebaseio.com/Menu")
        self.getAllDataForMenu()
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
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        
        
        let key = self.menu[indexPath.section]["name"] as! String
        if let item = self.itemsDict[key] {
            let keys = item.allKeys as! [String]
            if let object = item[keys[indexPath.row]] as? NSDictionary {
                cell.textLabel?.text = keys[indexPath.row]
                cell.detailTextLabel?.text = ""
                if let price = object["price"] as? Int {
                    if price > 0 {
                        cell.detailTextLabel?.text = "Rs. \(price)"
                    }
                }
            }
            
            cell.imageView?.image = UIImage(named: "cupcake")?.tintWithColor(self.getRandomColor())
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
        sectionTitle.textColor = UIColor.blackColor()
        sectionTitle.font = UIFont.systemFontOfSize(15)
        sectionView.addSubview(sectionTitle)
        
        let detailTitle = UILabel(frame: CGRectMake(self.menuTable.frame.size.width/2,0, self.menuTable.frame.size.width/2 - 15, 40))
        if let extra = self.menu[section]["extra"] as? String {
            detailTitle.text = extra
        }
        detailTitle.textAlignment = NSTextAlignment.Right
        detailTitle.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.1)
        detailTitle.textColor = UIColor.blackColor()
        detailTitle.font = UIFont.systemFontOfSize(12)
        sectionView.addSubview(detailTitle)
        
        sectionView.backgroundColor = UIColor.orangeColor()
        
        return sectionView
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
}
