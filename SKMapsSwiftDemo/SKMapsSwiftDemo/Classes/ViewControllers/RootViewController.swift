//
//  RootViewController.swift
//  SKMapsSwiftDemo
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

import Foundation
import UIKit
import SKMaps

class RootViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var dataSource: Array<Array<String>>!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "SKMaps Demo"
        
        let featuresTableView: UITableView = UITableView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        featuresTableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        featuresTableView.delegate = self;
        featuresTableView.dataSource = self;
        self.view.addSubview(featuresTableView)

        dataSource = [["Map display","Map creator", "Map styles", "Annotations", "Overlays", "HeatMaps","Map JSON & download"],["Routing & Navigation", "Alternative routes", "Real reach", "Tracks", "POI tracking", "Navigation UI"], ["Address search - offline", "Category search", "One Box search"]];
        
    }

    // MARK: UITableViewDatasource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50;
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40;
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionTitle: String?
        switch section {
        case 0:
            sectionTitle = "Map"
        case 1:
            sectionTitle = "Navigation"
        case 2:
            sectionTitle = "Search"
        default:
            sectionTitle = ""
        }
        
        return sectionTitle
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier: String? = "cellIdentifier"
        var cell:UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier!)
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        
        cell!.selectionStyle = UITableViewCellSelectionStyle.None
        cell!.textLabel!.text = dataSource[indexPath.section][indexPath.row]
        
        return cell!
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0,0):
            let mapVC: MapDisplayViewController = MapDisplayViewController()
            self.navigationController?.pushViewController(mapVC, animated: true)
        case (0,1):
            let mapCreatorVC: MapCreatorViewController = MapCreatorViewController()
            self.navigationController?.pushViewController(mapCreatorVC, animated: true)
        case (0,2):
            let mapStylesVC: MapStylesViewController = MapStylesViewController()
            self.navigationController?.pushViewController(mapStylesVC, animated: true)
        case (0,3):
            let annotationsVC: AnnotationsViewController = AnnotationsViewController()
            self.navigationController?.pushViewController(annotationsVC, animated: true)
        case (0,4):
            let overlaysVC: OverlaysViewController = OverlaysViewController()
            self.navigationController?.pushViewController(overlaysVC, animated: true)
        case (0,5):
            let heatmapsVC: HeatMapSettingsViewController = HeatMapSettingsViewController()
            self.navigationController?.pushViewController(heatmapsVC, animated: true)
        case (0,6):
            let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let packages : Array<SKTPackage>? = (appDelegate.skMapsObject?.packagesForType(.Continent) as? Array<SKTPackage>)
            let mapJSONVC: MapJSONViewController =  MapJSONViewController()
            mapJSONVC.packages = packages
            self.navigationController?.pushViewController(mapJSONVC, animated: true)
        case (1,0):
            let routingVC: RoutingViewController = RoutingViewController()
            self.navigationController?.pushViewController(routingVC, animated: true)
        case (1,1):
            let alternativesVC: AlternativeRoutesViewController = AlternativeRoutesViewController()
            self.navigationController?.pushViewController(alternativesVC, animated: true)
        case (1,2):
            let realReachVC: RealReachViewController = RealReachViewController()
            self.navigationController?.pushViewController(realReachVC, animated: true)
        case (1,3):
            let tracksVC: TracksViewController = TracksViewController()
            self.navigationController?.pushViewController(tracksVC, animated: true)
        case (1,4):
            let poiTrackingVC: POITrackerViewController = POITrackerViewController()
            self.navigationController?.pushViewController(poiTrackingVC, animated: true)
        case (1,5):
            let navigationUIVC: NavigationUIViewController = NavigationUIViewController()
            self.navigationController?.pushViewController(navigationUIVC, animated: true)
        case (2,0):
            let multiStepSearchVC: MultiStepSearchViewController = MultiStepSearchViewController()
            multiStepSearchVC.datasource = SKMapsService.sharedInstance().packagesManager.installedOfflineMapPackages;
            multiStepSearchVC.multiStepObject.listLevel = .CountryList
            self.navigationController?.pushViewController(multiStepSearchVC, animated: true)
        case (2, 1):
            let categorySearchVC: CategorySearchViewController = CategorySearchViewController()
            self.navigationController?.pushViewController(categorySearchVC, animated: true)
        case (2, 2):
            let oneBoxSearchVC: OneBoxSearchViewController = OneBoxSearchViewController()
            self.navigationController?.pushViewController(oneBoxSearchVC, animated: true)
        default:
            break
        }
    }
    
    
}