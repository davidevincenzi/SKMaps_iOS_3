//
//  RoutingViewController.swift
//  SKMapsSwiftDemo
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

import Foundation
import SKMaps

enum ButtonTags: Int
{
    case CalculateRoute = 100
    case StartNavigation
    case StopNavigation
}

class RoutingViewController: UIViewController, UIAlertViewDelegate, SKMapViewDelegate, SKRoutingDelegate, SKNavigationDelegate {
    
    var mapView: SKMapView!
    var bottomButton: UIButton!
    
    //MARK: Lifecycle
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.configureAudioPlayer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = SKMapView(frame: CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)))
        mapView.delegate = self
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.view.addSubview(self.mapView)
        
        mapView.settings.showCurrentPosition = true
        
        SKRoutingService.sharedInstance().mapView = mapView
        SKRoutingService.sharedInstance().routingDelegate = self
        SKRoutingService.sharedInstance().navigationDelegate = self
        
        self.addButton()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        mapView.settings.displayMode = SKMapDisplayMode.Mode2D
        
        AudioService.sharedInstance().cancel()
        SKRoutingService.sharedInstance().stopNavigation()
        SKRoutingService.sharedInstance().clearCurrentRoutes()

    }
    
    //MARK: UI Adding
    
    private func addButton() {
        bottomButton = UIButton(type:.System)
        bottomButton.frame = CGRectMake(50.0, CGRectGetHeight(self.view.frame)-40.0, CGRectGetWidth(self.view.frame)-100.0, 35.0)
        bottomButton.setTitle("Calculate Route", forState: UIControlState.Normal)
        bottomButton.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleBottomMargin]
        bottomButton.tag = ButtonTags.CalculateRoute.rawValue
        bottomButton.addTarget(self, action: #selector(RoutingViewController.buttonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        bottomButton.backgroundColor = UIColor.lightGrayColor()
        self.view.addSubview(bottomButton)
    }
    
    func buttonPressed(sender: UIButton) {
        let tag: ButtonTags = ButtonTags(rawValue: sender.tag)!
        switch tag {
        case .CalculateRoute:
            let route: SKRouteSettings = SKRouteSettings()
            route.startCoordinate = CLLocationCoordinate2DMake(37.9667, 23.7167)
            route.destinationCoordinate = CLLocationCoordinate2DMake(37.9677, 23.7567)
            route.shouldBeRendered = true // If NO, the route will not be rendered.
            route.requestAdvices = true
            route.maximumReturnedRoutes = 1
            route.requestExtendedRoutePointsInfo = true
            SKRoutingService.sharedInstance().calculateRoute(route)
        case .StartNavigation:
            let navSettings: SKNavigationSettings = SKNavigationSettings()
            navSettings.navigationType = SKNavigationType.Simulation
            navSettings.distanceFormat = SKDistanceFormat.MilesFeet
            mapView.settings.displayMode = SKMapDisplayMode.Mode3D
            SKRoutingService.sharedInstance().startNavigationWithSettings(navSettings)
            
            bottomButton.setTitle("Stop Navigation", forState: UIControlState.Normal)
            bottomButton.tag = ButtonTags.StopNavigation.rawValue
        case .StopNavigation:
            AudioService.sharedInstance().cancel()
            SKRoutingService.sharedInstance().stopNavigation()
            SKRoutingService.sharedInstance().clearCurrentRoutes()
            mapView.settings.displayMode = SKMapDisplayMode.Mode2D
            bottomButton.setTitle("Calculate Route", forState: UIControlState.Normal)
            bottomButton.tag = ButtonTags.CalculateRoute.rawValue
        }
    }
    
    //MARK: Audio Player
    
    private func configureAudioPlayer() {
        let mainBundlePath: String = NSBundle.mainBundle().resourcePath! + ("/SKAdvisorResources.bundle")
        let advisorResourcesBundle: NSBundle =  NSBundle(path:mainBundlePath)!
        let soundFilesFolder: String = advisorResourcesBundle.pathForResource("Languages", ofType: "")!
        let currentLanguage: String = "en_us"
        let audioFilesFolderPath: String = soundFilesFolder + "/" +  currentLanguage + "/" + "sound_files"
        
        AudioService.sharedInstance().audioFilesFolderPath = audioFilesFolderPath
        let settings: SKAdvisorSettings = SKAdvisorSettings()
        settings.advisorVoice = currentLanguage
        SKRoutingService.sharedInstance().advisorConfigurationSettings = settings
    }
    
    //MARK: SKRoutingService delegate - Routing
    
    func routingService(routingService: SKRoutingService!, didFinishRouteCalculationWithInfo routeInformation: SKRouteInformation!) {
        print("Route is calculated.")
        bottomButton.setTitle("Start Navigation", forState: UIControlState.Normal)
        bottomButton.tag = ButtonTags.StartNavigation.rawValue
        routingService.zoomToRouteWithInsets(UIEdgeInsetsZero, duration: 1)
        
        let advices: Array<SKRouteAdvice> =  SKRoutingService.sharedInstance().routeAdviceListWithDistanceFormat(SKDistanceFormat.Metric) as! Array<SKRouteAdvice>
        for advice: SKRouteAdvice in advices
        {
            print(advice.adviceInstruction)
        }
        
       let routeID: Int32 = Int32(routeInformation.routeID)
       let coords: Array<CLLocation>  =  SKRoutingService.sharedInstance().routeCoordinatesForRouteWithId(routeID) as! Array<CLLocation>
       let countSentence: String = "Route contains " + String(coords.count) + " elements"
       print(countSentence)
    }
    
    func routingService(routingService: SKRoutingService!, didFailWithErrorCode errorCode: SKRoutingErrorCode) {
        print("Route calculation failed.")
    }
    
    
    //MARK: SKRoutingService delegate - Navigation
    
    func routingService(routingService: SKRoutingService!, didChangeDistanceToDestination distance: Int32, withFormattedDistance formattedDistance: String!) {
        let distance = "distanceToDestination " + formattedDistance
        print(distance)
    }
    
    func routingService(routingService: SKRoutingService!, didChangeEstimatedTimeToDestination time: Int32) {
        print("timeToDestination " + String(time))
    }
    
    func routingService(routingService: SKRoutingService!, didChangeCurrentStreetName currentStreetName: String!, streetType: SKStreetType, countryCode: String!) {
        let streetTypeString: String = String(streetType.rawValue)
        let sentence: String = "Current street name changed to name=" + currentStreetName + " type=" + streetTypeString + " countryCode=" + countryCode
        print(sentence)
    }
    
    func routingService(routingService: SKRoutingService!, didChangeNextStreetName nextStreetName: String!, streetType: SKStreetType, countryCode: String!) {
        let streetTypeString: String = String(streetType.rawValue)
        let sentence: String = "Next street name changed to name=" + nextStreetName + " type=" + streetTypeString + " countryCode=" + countryCode
        print(sentence)
    }
    
    func routingService(routingService: SKRoutingService!, didChangeCurrentAdviceImage adviceImage: UIImage!, withLastAdvice isLastAdvice: Bool) {
        print("Current visual advice image changed.")
    }
    
    func routingService(routingService: SKRoutingService!, didChangeCurrentVisualAdviceDistance distance: Int32, withFormattedDistance formattedDistance: String!) {
        let sentence: String = "Current visual advice distance changed to distance=" + formattedDistance
        print(sentence)
    }
    
    func routingService(routingService: SKRoutingService!, didChangeSecondaryAdviceImage adviceImage: UIImage!, withLastAdvice isLastAdvice: Bool) {
        print("Secondary visual advice image changed.")
    }
    
    
    func routingService(routingService: SKRoutingService!, didChangeSecondaryVisualAdviceDistance distance: Int32, withFormattedDistance formattedDistance: String!) {
        let sentence: String = "Secondary visual advice distance changed to distance=" + formattedDistance
        print(sentence)
    }
    
    func routingService(routingService: SKRoutingService!, didUpdateFilteredAudioAdvices audioAdvices: [AnyObject]!) {
        AudioService.sharedInstance().play(audioAdvices as! Array<String>)
    }
    
    func routingService(routingService: SKRoutingService!, didUpdateUnfilteredAudioAdvices audioAdvices: [AnyObject]!, withDistance distance: Int32) {
        print("Unfiltered audio advice updated.")
    }
    
    func routingService(routingService: SKRoutingService!, didChangeCurrentSpeed speed: Double) {
        let speedString: String = "Current speed: " + String(format:"%.2f", speed)
        print(speedString)
    }
    
    func routingService(routingService: SKRoutingService!, didChangeCurrentSpeedLimit speedLimit: Double) {
        let speedString: String = "Current speedlimit: " + String(format:"%.2f", speedLimit)
        print(speedString)
    }
    
    func routingServiceDidStartRerouting(routingService: SKRoutingService!) {
        print("Rerouting started.")
    }
    
    func routingService(routingService: SKRoutingService!, didUpdateSpeedWarningToStatus speedWarningIsActive: Bool, withAudioWarnings audioWarnings: [AnyObject]!, insideCity isInsideCity: Bool) {
        print("Speed warning status updated.")
    }
    
    func routingServiceDidReachDestination(routingService: SKRoutingService!) {
        let message: String? = NSLocalizedString("navigation_screen_destination_reached_alert_message", comment: "")
        let cancelButtonTitle: String? = NSLocalizedString("navigation_screen_destination_reached_alert_ok_button_title", comment: "")
        
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: cancelButtonTitle, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}
