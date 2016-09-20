//
//  MapDisplayViewController.swift
//  SKMapsSwiftDemo
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

import Foundation
import SKMaps

class MapDisplayViewController: UIViewController, SKMapViewDelegate {
    
    var mapView: SKMapView!
    
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
        
        self.addUI()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        mapView.settings.showCurrentPosition = false
        mapView.settings.showCompass = false
    }
    
    //MARK: UI Adding
    
    private func addUI() {
        
        let positionMeButton: UIButton = UIButton(type:.System)
        positionMeButton.frame = CGRectMake(10.0, CGRectGetHeight(self.view.frame) - 60.0, 100.0, 40.0)
        positionMeButton.setTitle("Position me", forState: UIControlState.Normal)
        positionMeButton.addTarget(self, action:#selector(MapDisplayViewController.positionMe), forControlEvents: UIControlEvents.TouchUpInside)
        positionMeButton.backgroundColor = UIColor.lightGrayColor()
        positionMeButton.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin
        positionMeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.view.addSubview(positionMeButton);
        
        
        let positionPlusHeadingButton: UIButton = UIButton(type:.System)
        positionPlusHeadingButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 110.0, CGRectGetHeight(self.view.frame) - 60.0, 100.0, 40.0)
        positionPlusHeadingButton.setTitle("Show heading", forState: UIControlState.Normal)
        positionPlusHeadingButton.addTarget(self, action:#selector(MapDisplayViewController.showPositionerWithHeading), forControlEvents: UIControlEvents.TouchUpInside)
        positionPlusHeadingButton.backgroundColor = UIColor.lightGrayColor()
        positionPlusHeadingButton.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin
        positionPlusHeadingButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.view.addSubview(positionPlusHeadingButton);
    }
    
    internal func positionMe() {
        mapView.settings.showCurrentPosition = true
        mapView.settings.followUserPosition = true
        mapView.settings.headingMode = SKHeadingMode.RotatingHeading
        mapView.centerOnCurrentPosition()
    }
    
    func showPositionerWithHeading() {
        mapView.settings.followUserPosition = true
        mapView.settings.headingMode = SKHeadingMode.RotatingMap
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
