//
//  MultiStepSearchViewController.swift
//  SKMapsSwiftDemo
//
//  Copyright © 2015 skobbler. All rights reserved.
//

import UIKit
import SKMaps

class MultiStepSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SKSearchServiceDelegate {
    
    var multiStepObject: SKMultiStepSearchSettings = SKMultiStepSearchSettings()
    var tableView: UITableView!
    var datasource: NSArray = NSArray()
    
    // Mark:- Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView = UITableView(frame: self.view.frame)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        self.view.addSubview(self.tableView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        SKSearchService.sharedInstance().searchServiceDelegate = self
        SKSearchService.sharedInstance().searchResultsNumber = 500
        SKMapsService.sharedInstance().connectivityMode = .Offline
        
        if self.datasource.count == 0 {
            if self.multiStepObject.listLevel == .CountryList {
                let alert = UIAlertView(title: "", message: "No packages are downloaded. For downloading map packages go to the Map XML & download screen.", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            } else {
                let alert = UIAlertView(title: "", message: "The OpenStreetMap does not have feature any street/house number in your selected city.", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        SKMapsService.sharedInstance().connectivityMode = .Online
    }

    // MARK: - Table view data source

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datasource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell
        
        if self.multiStepObject.listLevel == .CountryList {
            let mapPackage: SKMapPackage = self.datasource .objectAtIndex(indexPath.row) as! SKMapPackage
            cell.textLabel?.text = mapPackage.name
        } else {
            let searchResult: SKSearchResult = self.datasource.objectAtIndex(indexPath.row) as! SKSearchResult
            cell.textLabel?.text = searchResult.name
            cell.detailTextLabel?.text = "Coordinate: (\(searchResult.coordinate.latitude), \(searchResult.coordinate.longitude))"
        }

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let mapPackage = self.datasource.objectAtIndex(indexPath.row) as? SKMapPackage {
            let multiStepSearchObject: SKMultiStepSearchSettings = SKMultiStepSearchSettings()
            multiStepSearchObject.listLevel = SKListLevel.CityList
            multiStepSearchObject.offlinePackageCode = mapPackage.name
            multiStepSearchObject.searchTerm = ""
            multiStepSearchObject.parentIndex = 0
            SKSearchService.sharedInstance().startMultiStepSearchWithSettings(multiStepSearchObject)
            self.multiStepObject = multiStepSearchObject
        } else if let searchResult = self.datasource.objectAtIndex(indexPath.row) as? SKSearchResult {
            let multiStepSearchObject: SKMultiStepSearchSettings = SKMultiStepSearchSettings()
            multiStepSearchObject.listLevel = self.multiStepObject.listLevel
            multiStepObject.offlinePackageCode = self.multiStepObject.offlinePackageCode
            multiStepObject.searchTerm = ""
            multiStepObject.parentIndex = searchResult.identifier
            SKSearchService.sharedInstance().startMultiStepSearchWithSettings(multiStepObject)
        }
    }
    
    func searchService(searchService: SKSearchService!, didRetrieveMultiStepSearchResults searchResults: [AnyObject]!) {
        let multiStepObjectCopy = SKMultiStepSearchSettings()
        multiStepObjectCopy.offlinePackageCode = self.multiStepObject.offlinePackageCode
        multiStepObjectCopy.listLevel = (self.multiStepObject.listLevel == .CountryList) ? SKListLevel.CityList : SKListLevel(rawValue: (self.multiStepObject.listLevel.rawValue + 1))!
        
        let multiStepSearchVC = MultiStepSearchViewController()
        multiStepSearchVC.datasource = searchResults
        multiStepSearchVC.multiStepObject = multiStepObjectCopy
        self.navigationController?.pushViewController(multiStepSearchVC, animated: true)
    }
    
    func searchServiceDidFailToRetrieveMultiStepSearchResults(searchService: SKSearchService!) {
        print("failed to retrieve results")
    }
    
}
