//
//  HeatMapSettingsViewController.swift
//  SKMapsSwiftDemo
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

import Foundation
import UIKit
import SKMaps

class HeatMapSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var datasource:  NSDictionary!// Dictionary<SKPOIMainCategory,Array<SKPOICategory>>!
    var tableView: UITableView!
    var selectedArray: Array<NSNumber>!
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupDatasource()
        self.addTableView()
        self.addButton()
    }

    //MARK: UI Adding
    
    private func addTableView() {
        let tableViewRect: CGRect = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height)
        
        tableView =  UITableView(frame: tableViewRect, style: UITableViewStyle.Grouped)
        tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 50.0;
        tableView.decelerationRate = UIScrollViewDecelerationRateFast
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.lightGrayColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        tableView.showsVerticalScrollIndicator = false
        self.view.addSubview(tableView)
    }
    
    private func addButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Map", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(HeatMapSettingsViewController.showMap))
    }
    
    func showMap() {
        let heatMapVC: HeatMapViewController = HeatMapViewController()
        heatMapVC.datasource = selectedArray
        self.navigationController?.pushViewController(heatMapVC, animated: true)
    }
    
    //MARK: Datasource processing

    private func setupDatasource() {
       // let oldDictionary: NSDictionary = SKSearchService.sharedInstance().categoriesFromMainCategories
       // datasource = oldDictionary as Dictionary<NSObject, AnyObject> as Dictionary<SKPOIMainCategory, Array<SKPOICategory>>
        datasource = SKSearchService.sharedInstance().categoriesFromMainCategories
        selectedArray = []
    }
    
    //MARK: UITableViewDatasource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return datasource.count - 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let mainCateg: NSNumber = NSNumber(integer: section + 1)
        let subcategs: Array<Int> = datasource.objectForKey(mainCateg) as! Array<Int>
        return subcategs.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var sectionHeader: String?
        switch (section) {
        case 0:
            sectionHeader = NSLocalizedString("category_food_type_title_key", comment:"Food")
        case 1:
            sectionHeader = NSLocalizedString("category_health_type_title_key", comment:"Health")
        case 2:
            sectionHeader = NSLocalizedString("category_leisure_type_title_key", comment:"Leisure")
        case 3:
            sectionHeader = NSLocalizedString("category_nightlife_type_title_key", comment:"NightLife")
        case 4:
            sectionHeader = NSLocalizedString("category_public_type_title_key", comment:"Public")
        case 5:
            sectionHeader = NSLocalizedString("category_service_type_title_key", comment:"Service")
        case 6:
            sectionHeader = NSLocalizedString("category_shopping_type_title_key", comment:"Shopping")
        case 7:
            sectionHeader = NSLocalizedString("category_sleeping_type_title_key", comment:"Sleeping")
        case 8:
            sectionHeader = NSLocalizedString("category_transport_type_title_key", comment:"Transport")
        default:
            break
        }
        
        return sectionHeader
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier: String? = "cellIdentifier"
        var cell:UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier!)
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        
        let key: NSNumber = NSNumber(integer: indexPath.section + 1)
        let subcategs: Array<Int> = datasource.objectForKey(key) as! Array<Int>
        let currentValue: NSNumber! = NSNumber(integer: subcategs[indexPath.row])
        
        let categoryValue: String! = "category_" +  String(currentValue.integerValue)
        
        cell!.textLabel!.text = NSLocalizedString(categoryValue , comment: "")
        cell!.selectionStyle = UITableViewCellSelectionStyle.None
        
        if  selectedArray.contains(currentValue) {
            cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        else {
             cell!.accessoryType = UITableViewCellAccessoryType.None
        }
        
        return cell!
    }
    
    
    //MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let key: NSNumber = NSNumber(integer: indexPath.section + 1)
        let subcategs: Array<Int> = datasource.objectForKey(key) as! Array<Int>
        let currentValue: NSNumber! = subcategs[indexPath.row]
        
        if  selectedArray.contains(currentValue) {
            selectedArray = selectedArray.filter({$0 != currentValue.integerValue})
        }
        else {
            selectedArray.append(currentValue)
        }
        
        tableView.reloadData()
    }
}