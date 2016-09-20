//
//  AlternativeRoutesViewController.swift
//  SKMapsSwiftDemo
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

import Foundation
import SKMaps

class AlternativeRoutesViewController: UIViewController, SKRoutingDelegate {
    
    var mapView: SKMapView!
    var nrOfRoutesAvailable: Int = 0
    var routes: Array<SKRouteInformation>!
    var alternativeRoutesSegControl: UISegmentedControl!
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = SKMapView(frame: CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)))
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.view.addSubview(self.mapView)
        
        mapView.settings.showCurrentPosition = true
        
        SKRoutingService.sharedInstance().mapView = mapView
        SKRoutingService.sharedInstance().routingDelegate = self
        
        self.addSegmentedControl()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let route: SKRouteSettings = SKRouteSettings()
        route.startCoordinate = CLLocationCoordinate2DMake(37.9667, 23.7167)
        route.destinationCoordinate = CLLocationCoordinate2DMake(37.9677, 23.7567)
        route.maximumReturnedRoutes = 3
        route.routeMode = SKRouteMode.CarEfficient
        SKRoutingService.sharedInstance().calculateRoute(route)
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        SKRoutingService.sharedInstance().clearCurrentRoutes()
    }
    
    //MARK: UI Adding
    
    private func addSegmentedControl() {
        alternativeRoutesSegControl =  UISegmentedControl(items: ["-","-","-"])
        alternativeRoutesSegControl.frame = CGRectMake(0.0, 80.0, CGRectGetWidth(self.view.frame), 30.0)
        alternativeRoutesSegControl.addTarget(self, action: #selector(AlternativeRoutesViewController.alternativeRouteChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        alternativeRoutesSegControl.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin]
        self.view.addSubview(alternativeRoutesSegControl)
        
        routes = Array()
        
        for i in 0...alternativeRoutesSegControl.numberOfSegments - 1 {
            alternativeRoutesSegControl.setEnabled(false, forSegmentAtIndex: i)
            
        }
    }
    
    func alternativeRouteChanged(control: UISegmentedControl)
    {
        let index: Int = control.selectedSegmentIndex;
        let routeInformation: SKRouteInformation = routes[index] as SKRouteInformation
        SKRoutingService.sharedInstance().mainRouteId = routeInformation.routeID
    }
    
    //MARK: SKRouting delegate
    
    func routingService(routingService: SKRoutingService!, didFinishRouteCalculationWithInfo routeInformation: SKRouteInformation!) {
        let routeID: String = String(routeInformation.routeID)
        print("Route is calculated with id " + routeID)
        
        routes.append(routeInformation)
        
        alternativeRoutesSegControl.setTitle(String(nrOfRoutesAvailable), forSegmentAtIndex: nrOfRoutesAvailable)
        alternativeRoutesSegControl.setEnabled(true, forSegmentAtIndex: nrOfRoutesAvailable)
        
        if nrOfRoutesAvailable == 0
        {
            alternativeRoutesSegControl.selectedSegmentIndex = 0
            SKRoutingService.sharedInstance().zoomToRouteWithInsets(UIEdgeInsetsZero, duration: 1)
        }
        
        nrOfRoutesAvailable += 1
    }
    
    func routingService(routingService: SKRoutingService!, didFailWithErrorCode errorCode: SKRoutingErrorCode) {
        print("Route calculation failed")
    }
}