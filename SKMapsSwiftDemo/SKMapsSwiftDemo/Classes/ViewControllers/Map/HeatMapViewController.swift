//
//  HeatMapViewController.swift
//  SKMapsSwiftDemo
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

import Foundation
import SKMaps

class HeatMapViewController: UIViewController, SKMapViewDelegate {
    
    var mapView: SKMapView!
    var datasource: Array<NSNumber>!
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = SKMapView(frame: CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)))
        mapView.delegate = self
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.view.addSubview(self.mapView)
        
        //setting the visible region
        let region: SKCoordinateRegion = SKCoordinateRegion(center: CLLocationCoordinate2DMake(52.5233, 13.4127), zoomLevel: 17)
        mapView.visibleRegion = region
        
        mapView.showHeatMapWithPOIType(datasource)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        mapView.settings.showCurrentPosition = false
        mapView.settings.showCompass = false
        
        mapView.clearHeatMap()
    }
    
    //MARK: SKMapViewDelegate
    
    
    func mapViewDidSelectCompass(mapView: SKMapView!) {
        mapView.settings.followUserPosition = true
        mapView.settings.headingMode = SKHeadingMode.RotatingHeading
        mapView.animateToBearing(0.0)
        mapView.settings.showCompass = false
    }
    
    func mapView(mapView: SKMapView!, didRotateWithAngle angle: Float) {
        mapView.settings.compassOffset = CGPointMake(0.0, 64.0)
        mapView.settings.showCompass = true
    }

}
