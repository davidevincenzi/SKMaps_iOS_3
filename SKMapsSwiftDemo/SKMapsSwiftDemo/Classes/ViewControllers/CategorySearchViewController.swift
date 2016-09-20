//
//  CategorySearchViewController.swift
//  SKMapsSwiftDemo
//
//  Created by CsongorK on 29/07/15.
//  Copyright (c) 2015 skobbler. All rights reserved.
//

import UIKit
import SKMaps

class CategorySearchViewController: UIViewController, UITableViewDelegate, SKSearchServiceDelegate {

    var distanceSegmentedControl: UISegmentedControl!
    var resultsTableView: UITableView!
    var dataSource: NSMutableArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addUI()
        self.startSearch()
    }
    
    func addUI() {
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.distanceSegmentedControl = UISegmentedControl(items: ["2000", "5000", "8000"])
        self.distanceSegmentedControl.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 40.0)
        self.distanceSegmentedControl.selectedSegmentIndex = 0
        self.view.addSubview(self.distanceSegmentedControl)
        
        self.resultsTableView = UITableView(frame: CGRectMake(0.0, self.distanceSegmentedControl.frame.height, self.view.frame.size.width, self.view.frame.size.height - self.distanceSegmentedControl.frame.size.height))
        self.resultsTableView.delegate = self
//        self.resultsTableView.dataSource = self
        self.view.addSubview(self.resultsTableView)
        
    }
    
    func startSearch() {
        /*
        int radius = [self radiusFromSegmentedControl];
        
        [[SKSearchService sharedInstance]cancelSearch];
        [SKSearchService sharedInstance].searchServiceDelegate = self;
        
        SKNearbySearchSettings* searchObject = [SKNearbySearchSettings nearbySearchSettings];
        searchObject.coordinate = CLLocationCoordinate2DMake(37.9667, 23.7167);
        searchObject.searchTerm=@"";
        searchObject.radius=radius;
        searchObject.searchMode=SKSearchHybrid;
        searchObject.searchResultSortType=SKProximitySort;
        searchObject.searchCategories = @[@(SKPOICategoryAirport),@(SKPOICategoryAtm),@(SKPOICategoryAccessoires),@(SKPOICategoryCar),@(SKPOICategoryUniversity),@(SKPOICategorySupermarket)];
        [[SKSearchService sharedInstance] setSearchResultsNumber:10000];
        [[SKSearchService sharedInstance]startNearbySearchWithSettings:searchObject];
*/
        
        
        let nearbySearchSettings = SKNearbySearchSettings()
        nearbySearchSettings.coordinate = CLLocationCoordinate2DMake(37.9667, 23.7167)
        nearbySearchSettings.searchTerm = ""
        nearbySearchSettings.radius = 2000
//        nearbySearchSettings.searchMode = Hybrid
//        nearbySearchSettings.searchResultSortType = SKProximitySort
//        nearbySearchSettings.searchCategories = [NSNumber]
        
        SKSearchService.sharedInstance().cancelSearch()
        SKSearchService.sharedInstance().searchServiceDelegate = self
        SKSearchService.sharedInstance().searchResultsNumber = 10000
        SKSearchService.sharedInstance().startNearbySearchWithSettings(nearbySearchSettings)
    }
    
    func searchService(searchService: SKSearchService!, didRetrieveNearbySearchResults searchResults: [AnyObject]!, withSearchMode searchMode: SKSearchMode) {
    
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
}
