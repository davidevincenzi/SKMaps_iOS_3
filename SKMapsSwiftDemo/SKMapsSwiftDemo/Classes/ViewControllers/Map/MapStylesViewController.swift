//
//  MapStylesViewController.swift
//  SKMapsSwiftDemo
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

import Foundation
import SKMaps

class MapStylesViewController: UIViewController, SKMapViewDelegate {
    
    var mapView: SKMapView!
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = SKMapView(frame: CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)))
        mapView.delegate = self
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.view.addSubview(self.mapView)
        
        let mapViewStyle: SKMapViewStyle = SKMapViewStyle()
        mapViewStyle.resourcesFolderName = "DayStyle";
        mapViewStyle.styleFileName = "daystyle.json";
        SKMapView.setMapStyle(mapViewStyle)
        
        self.addUI()
    }
    
    
    //MARK: UI Adding
    
    private func addUI() {
        let segmentedControl: UISegmentedControl = UISegmentedControl(items: ["Day","Night","Outdoor","Gray"])
        segmentedControl.backgroundColor = UIColor.lightGrayColor()
        segmentedControl.frame = CGRectMake(5.0, CGRectGetHeight(self.view.frame) - 55.0 , CGRectGetWidth(self.view.frame) - 10.0, 30.0);
        segmentedControl.autoresizingMask =  [.FlexibleWidth, .FlexibleTopMargin]
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(MapStylesViewController.segmentedControlValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(segmentedControl)
    }
    
    func segmentedControlValueChanged(segmentedControl: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            let mapViewStyle: SKMapViewStyle = SKMapViewStyle()
            mapViewStyle.resourcesFolderName = "DayStyle";
            mapViewStyle.styleFileName = "daystyle.json";
            SKMapView.setMapStyle(mapViewStyle)
        case 1:
            let mapViewStyle: SKMapViewStyle = SKMapViewStyle()
            mapViewStyle.resourcesFolderName = "NightStyle";
            mapViewStyle.styleFileName = "nightstyle.json";
            SKMapView.setMapStyle(mapViewStyle)
        case 2:
            let mapViewStyle: SKMapViewStyle = SKMapViewStyle()
            mapViewStyle.resourcesFolderName = "OutdoorStyle";
            mapViewStyle.styleFileName = "outdoorstyle.json";
            SKMapView.setMapStyle(mapViewStyle)
        case 3:
            let mapViewStyle: SKMapViewStyle = SKMapViewStyle()
            mapViewStyle.resourcesFolderName = "GrayscaleStyle";
            mapViewStyle.styleFileName = "grayscalestyle.json";
            SKMapView.setMapStyle(mapViewStyle)
        default:
            return
        }
    }
    

}