//
//  POITrackerViewController.swift
//  SKMapsSwiftDemo
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

import Foundation
import SKMaps

private let kLogFileName: String = "Seattle"
private let kRadius: Int32 = 5000 //meters
private let kRefreshMargin: Double = 0.1
private let kTrackablePOITypeIncident: SKTrackablePOIType = 0

class POITrackerViewController: UIViewController, SKMapViewDelegate, SKRoutingDelegate, SKNavigationDelegate, SKPOITrackerDataSource, SKPOITrackerDelegate {
    
    var mapView: SKMapView!
    var poiTracker: SKPOITracker!
    var trackablePOIs: Array<SKTrackablePOI>!

    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = SKMapView(frame: CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)))
        mapView.delegate = self
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.view.addSubview(self.mapView)
        
        //setting the visible region
        let region: SKCoordinateRegion = SKCoordinateRegion(center: CLLocationCoordinate2DMake(48.207407, 16.376916), zoomLevel: 17)
        mapView.visibleRegion = region
        mapView.settings.followUserPosition = true
        mapView.settings.headingMode = SKHeadingMode.Route
        
        trackablePOIs = self.trackablePOIsForDemo()
        
        SKRoutingService.sharedInstance().navigationDelegate = self
        SKRoutingService.sharedInstance().routingDelegate = self
        SKRoutingService.sharedInstance().mapView = mapView
        
        self.startNavigationFromLog()
        self.startPOITracking()
        self.addAnnotations()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        SKRoutingService.sharedInstance().stopNavigation()
        poiTracker.stopPOITracker()
        self.removeAnnotations()
    }
    
    //MARK : Private methods
    
    private func trackablePOIsForDemo() -> Array<SKTrackablePOI>! {
        
        let trackablePOI1: SKTrackablePOI = SKTrackablePOI()
        trackablePOI1.poiID = 0
        trackablePOI1.type = kTrackablePOITypeIncident
        trackablePOI1.coordinate = CLLocationCoordinate2DMake(47.643421, -122.202824)
        
        let trackablePOI2: SKTrackablePOI = SKTrackablePOI()
        trackablePOI2.poiID = 1
        trackablePOI2.type = kTrackablePOITypeIncident
        trackablePOI2.coordinate = CLLocationCoordinate2DMake(47.641498, -122.197208)
        
        let trackablePOI3: SKTrackablePOI = SKTrackablePOI()
        trackablePOI3.poiID = 2
        trackablePOI3.type = kTrackablePOITypeIncident
        trackablePOI3.coordinate = CLLocationCoordinate2DMake(47.632820, -122.189305)
        
        let trackablePOI4: SKTrackablePOI = SKTrackablePOI()
        trackablePOI4.poiID = 3
        trackablePOI4.type = kTrackablePOITypeIncident
        trackablePOI4.coordinate = CLLocationCoordinate2DMake(47.629637, -122.170254)
        
        let trackablePOI5: SKTrackablePOI = SKTrackablePOI()
        trackablePOI5.poiID = 4
        trackablePOI5.type = kTrackablePOITypeIncident
        trackablePOI5.coordinate = CLLocationCoordinate2DMake(47.643981, -122.134178)
        
        return [trackablePOI1, trackablePOI2, trackablePOI3, trackablePOI4, trackablePOI5]

    }

    
    private func startNavigationFromLog() {
        
        let logFilePath: String = NSBundle.mainBundle().pathForResource(kLogFileName, ofType: "log")!
        SKPositionerService.sharedInstance().startPositionReplayFromLog(logFilePath)
        SKPositionerService.sharedInstance().setPositionReplayRate(2.0)
        
        let navigationSettings: SKNavigationSettings = SKNavigationSettings()
        navigationSettings.navigationType = SKNavigationType.SimulationFromLogFile
        SKRoutingService.sharedInstance().startNavigationWithSettings(navigationSettings)
    }
    
    private func startPOITracking() {
        
        let rule: SKTrackablePOIRule = SKTrackablePOIRule()
        rule.routeDistance = 1500
        rule.aerialDistance = 3000
        
        poiTracker = SKPOITracker()
        poiTracker.dataSource = self
        poiTracker.delegate = self
        poiTracker.setRule(rule, forPOIType: 0)
        poiTracker.setRule(rule, forPOIType: kTrackablePOITypeIncident)
        poiTracker.startPOITrackerWithRadius(kRadius, refreshMargin: kRefreshMargin, forPOITypes: [0])
    }
    
    private func addAnnotations() {
        
        let animationSettings: SKAnimationSettings = SKAnimationSettings()
        for poi: SKTrackablePOI in trackablePOIs {
            let annotation: SKAnnotation = SKAnnotation()
            annotation.identifier = poi.poiID
            annotation.location = poi.coordinate
            annotation.annotationType = SKAnnotationType.Marker
            
            mapView.addAnnotation(annotation, withAnimationSettings: animationSettings)
        }
    }
    
    private func removeAnnotations() {
        mapView.clearAllAnnotations()
    }

    
    //MARK : SKPOITrackerDataSource
    
    func poiTracker(poiTracker: SKPOITracker!, trackablePOIsAroundLocation location: CLLocationCoordinate2D, inRadius radius: Int32, withType poiType: Int32) -> [AnyObject]! {
       return trackablePOIs
    }
    
    //MARK : SKPOITrackerDelegate
    
    func poiTracker(poiTracker: SKPOITracker!, didDectectPOIs detectedPOIs: [AnyObject]!, withType type: Int32) {
        for poi in detectedPOIs as! Array<SKTrackablePOI> {
            print(poi.description)
        }
    }
    
}
