//
//  RealReachViewController.swift
//  SKMapsSwiftDemo
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

import Foundation
import SKMaps

class RealReachViewController: UIViewController {
    
    var mapView: SKMapView!
    var timeSlider: UISlider!
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = SKMapView(frame: CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)))
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.view.addSubview(self.mapView)
        
        //setting the visible region
        let region: SKCoordinateRegion = SKCoordinateRegion(center: CLLocationCoordinate2DMake(52.5237, 13.4137), zoomLevel: 17)
        mapView.visibleRegion = region
        
        let animationSettings: SKAnimationSettings = SKAnimationSettings()
        
        let annotation1: SKAnnotation = SKAnnotation()
        annotation1.identifier = 30
        annotation1.annotationType = SKAnnotationType.Red
        annotation1.location = CLLocationCoordinate2DMake(52.5237, 13.4137)
        
        self.mapView.addAnnotation(annotation1, withAnimationSettings: animationSettings)
        
        self.addSlider()
        
        let realReachSettings: SKRealReachSettings = SKRealReachSettings()
        realReachSettings.centerLocation = CLLocationCoordinate2DMake(52.5237, 13.4137)
        realReachSettings.transportMode = SKTransportMode.Pedestrian
        realReachSettings.unit = SKRealReachUnit.Second
        realReachSettings.connectionMode = SKRouteConnectionMode.Offline
        realReachSettings.range = 300 //5 min
        
        mapView.displayRealReachWithSettings(realReachSettings)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        mapView.clearRealReachDisplay()
    }
    
    //MARK: UI Adding
    
    private func addSlider() {
        
        timeSlider = UISlider(frame: CGRectMake(5.0, CGRectGetMinY(self.mapView.frame) + 70.0, CGRectGetWidth(self.view.frame)/2 - 5.0, 40.0))
        timeSlider.minimumValue = 0
        timeSlider.maximumValue = 3600
        timeSlider.addTarget(self, action: #selector(RealReachViewController.sliderValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        timeSlider.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        
        self.view.addSubview(timeSlider)
    }
    
    func sliderValueChanged(sender: UISlider) {
        let timeInSeconds: Int32 = Int32(timeSlider.value)
        
        let realReachSettings: SKRealReachSettings = SKRealReachSettings()
        realReachSettings.centerLocation = CLLocationCoordinate2DMake(52.5233, 13.4127)
        realReachSettings.transportMode = SKTransportMode.Pedestrian
        realReachSettings.unit = SKRealReachUnit.Second
        realReachSettings.connectionMode = SKRouteConnectionMode.Offline
        realReachSettings.range = timeInSeconds
        
        mapView.displayRealReachWithSettings(realReachSettings)
        

    }
    
}