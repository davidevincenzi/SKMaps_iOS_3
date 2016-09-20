//
//  GPSElementsDrawingViewController.swift
//  SKMapsSwiftDemo
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

import Foundation
import SKMaps

class GPSElementsDrawingViewController: UIViewController, SKMapViewDelegate {
    
    var mapView: SKMapView!
    var gpsElement: SKGPSFileElement!
    
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
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        mapView.settings.showCurrentPosition = true
        
        if gpsElement != nil
        {
            if gpsElement.type.rawValue == SKGPSFileElementType.GPXTrack.rawValue
            {
                do {
                    let gpsElements: Array<SKGPSFileElement>  = try SKGPSFilesService.sharedInstance().childElementsForElement(gpsElement) as! Array<SKGPSFileElement>
                    for element: SKGPSFileElement in gpsElements
                    {
                        mapView.drawGPSFileElement(element)
                        mapView.fitGPSFileElement(element)
                    }
                } catch {
                }
            }
            else
            {
                mapView.drawGPSFileElement(gpsElement)
                mapView.fitGPSFileElement(gpsElement)
            }
        }
        
    }
}
