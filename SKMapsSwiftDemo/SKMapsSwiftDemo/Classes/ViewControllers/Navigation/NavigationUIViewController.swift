//
//  NavigationUIViewController.swift
//  SKMapsSwiftDemo
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

import Foundation
import SKMaps

private let kStartAnnotationId: Int32 = 110
private let kEndAnnotationId: Int32 = 111

class NavigationUIViewController: UIViewController, UIAlertViewDelegate, SKMapViewDelegate, SKTNavigationManagerDelegate {
    
    var mapView: SKMapView!
    var centerButton: UIButton!
    var navigationManager: SKTNavigationManager!
    var poiView: UIView!
    var configuration: SKTNavigationConfiguration!
    var menu: MenuView!
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SKRoutingService.sharedInstance().advisorConfigurationSettings = SKAdvisorSettings()
        
        configuration = SKTNavigationConfiguration.defaultConfiguration()
        configuration.navigationType = SKNavigationType.Simulation
        configuration.startCoordinate = CLLocationCoordinate2DMake(52.517141427998148, 13.389737606048584)
        configuration.destination = CLLocationCoordinate2DMake(53.5653, 10.0014)
        
        self.addMapView()
        self.displayAlert()
        self.updateAnnotations()
        
        navigationManager =  SKTNavigationManager(mapView: mapView)
        self.view.addSubview(navigationManager.mainView)
        navigationManager.mainView.hidden = false
        navigationManager.mainView.isUnderStatusBar = false
        navigationManager.startNavigationWithConfiguration(configuration)
    
        navigationManager.mainView.orientation = UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? .Landscape : .Portrait
        
        self.navigationController!.navigationBar.translucent = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationManager.stopNavigation()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //MARK: Private methods
    
    private func addMapView() {
        
        mapView = SKMapView(frame: CGRectMake(0.0, 0.0, self.view.frameWidth, self.view.frameHeight))
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        mapView.delegate = self
        mapView.mapScaleView.hidden = true
        mapView.settings.rotationEnabled = false
        mapView.settings.showCurrentPosition = true
        
        let region: SKCoordinateRegion = SKCoordinateRegion(center: CLLocationCoordinate2DMake(52.517141427998148, 13.389737606048584), zoomLevel: 12.0)
        mapView.visibleRegion = region
        self.view.addSubview(mapView)
    }
    
    private func displayAlert() {
        let message: String? = "The start and destination points are hardcoded as: Berlin and Hamburg"
        let alert = UIAlertController(title: "Simulation", message: message , preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    private func updateAnnotations() {
        if !SKTNavigationUtils.locationIsZero(configuration.startCoordinate) {
            let annotation = SKAnnotation()
            annotation.location = configuration.startCoordinate
            annotation.identifier = kStartAnnotationId
            annotation.annotationType = SKAnnotationType.Green
            mapView.addAnnotation(annotation, withAnimationSettings: SKAnimationSettings())
        }
        else {
            mapView.removeAnnotationWithID(kStartAnnotationId)
        }
    }

    
    //MARK: SKTNavigationManagerDelegate
    
    func navigationManagerDidStopNavigation(manager: SKTNavigationManager, withReason reason: SKTNavigationStopReason) {
        //[self cancelNavigation];
        mapView.delegate = self;
    }
    
    func cancelNavigation() {
        navigationManager.mainView.hidden = true
        self.navigationController?.navigationBarHidden = false
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        
        SKPositionerService.sharedInstance().stopPositionReplay()
    }
    
}
