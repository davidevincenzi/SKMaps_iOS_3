//
//  MapJSONViewController.swift
//  SKMapsSwiftDemo
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

import Foundation

class MapJSONViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var activityIndicatorView: UIActivityIndicatorView!
    var mapRegionsTableView: UITableView!
    var packages: Array<SKTPackage>!
    var resultsArray: Array<SKTPackage>!
    
    //MARK: Lifecycle
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        packages = Array<SKTPackage>()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsArray = Array<SKTPackage>()
        self.addTableView()
        self.addActivityIndicator()
        
        if !MapJSONParser.sharedInstance().isParsingFinished {
            activityIndicatorView.hidden = false
            activityIndicatorView.startAnimating()
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "populateTableView", name:kParsingFinishedNotificationName , object: nil)
        }
        else {
            activityIndicatorView.hidden = true
            self.populateTableView()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //MARK: UI
    
    private func addTableView() {
        let tableViewRect: CGRect = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height)
        
        mapRegionsTableView =  UITableView(frame: tableViewRect, style: UITableViewStyle.Plain)
        mapRegionsTableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        mapRegionsTableView.dataSource = self
        mapRegionsTableView.delegate = self
        mapRegionsTableView.rowHeight = 50.0;
        mapRegionsTableView.decelerationRate = UIScrollViewDecelerationRateFast
        mapRegionsTableView.backgroundView = nil
        mapRegionsTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        mapRegionsTableView.showsVerticalScrollIndicator = false
        self.view.addSubview(mapRegionsTableView)
    }

    
    private func addActivityIndicator() {
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityIndicatorView.center = self.view.center
        self.view.addSubview(activityIndicatorView)
    }
    
    private func populateTableView()
    {
        resultsArray = packages
        mapRegionsTableView.reloadData()
    }
    
    internal func didTapDownloadButtonForRegion(sender: AnyObject)
    {
        let downloadButton: UIButton = sender as! UIButton
        let package: SKTPackage? =  resultsArray[downloadButton.tag]
        
        let mapDownloadVC: MapDownloadViewController = MapDownloadViewController()
        mapDownloadVC.regionToDownload = package
        self.navigationController?.pushViewController(mapDownloadVC, animated: true)
    }

    
    //MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier: String? = "cellIdentifier"
        var cell:UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier!)
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellIdentifier)
        }
        
        let package: SKTPackage = resultsArray[indexPath.row]
        cell!.textLabel!.text = package.nameForLanguageCode("en")
        cell!.selectionStyle = UITableViewCellSelectionStyle.None
        let childObjects: Array<SKTPackage> = package.childObjects() as! Array<SKTPackage>
        
        if childObjects.count > 0 {
            cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        else {
            cell!.accessoryType = UITableViewCellAccessoryType.None
        }
        
        if package.type != SKTPackageType.Continent
        {
            let positionMeButton: UIButton = UIButton(type:.System)
            positionMeButton.frame =  CGRectMake(200.0, 2.0, 100.0, 40.0)
            positionMeButton.tag = indexPath.row
            positionMeButton.setTitle("Download", forState: UIControlState.Normal)
            positionMeButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            positionMeButton.addTarget(self, action: #selector(MapJSONViewController.didTapDownloadButtonForRegion(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell!.contentView.addSubview(positionMeButton)
            let detailString: String = NSString(format:"TL:(%f,%f) BR:(%f,%f)",package.bbox.latMin,package.bbox.longMax,package.bbox.latMax,package.bbox.longMin) as String
            cell!.detailTextLabel!.text = detailString
            cell!.detailTextLabel!.font = UIFont.systemFontOfSize(10)
        }
        
        
        return cell!
    }
    
    //MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let package: SKTPackage = resultsArray[indexPath.row]
        let childObjects: Array<SKTPackage> = package.childObjects() as!  Array<SKTPackage>
        
        if childObjects.count > 0 {
            let mapJSONVC: MapJSONViewController =  MapJSONViewController()
            mapJSONVC.packages = childObjects
            self.navigationController?.pushViewController(mapJSONVC, animated: true)
        }
        
    }

}