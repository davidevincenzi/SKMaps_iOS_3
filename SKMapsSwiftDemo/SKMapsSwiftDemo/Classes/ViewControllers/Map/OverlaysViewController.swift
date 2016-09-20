//
//  OverlaysViewController.swift
//  SKMapsSwiftDemo
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

import Foundation
import SKMaps


class OverlaysViewController: UIViewController, SKMapViewDelegate {
    
    var mapView: SKMapView!
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = SKMapView(frame: CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)))
        mapView.delegate = self
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.view.addSubview(self.mapView)
        
        let region: SKCoordinateRegion = SKCoordinateRegion(center: CLLocationCoordinate2DMake(52.5233, 13.4127), zoomLevel: 15)
        mapView.visibleRegion = region
        
        self.addCircles()
        self.addPolygons()
        self.addPolylines()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        mapView.clearAllOverlays()
    }
    
    //MARK: UI Adding
    
    private func addCircles() {
        //adds a circle on the map without border
        let circle: SKCircle = SKCircle()
        circle.centerCoordinate = CLLocationCoordinate2DMake(52.5233 + 0.003, 13.4127 - 0.004)
        circle.radius = 100;
        circle.fillColor = UIColor(red: 244/255.0 , green: 71/255.0, blue: 140/255.0, alpha: 0.4)
        circle.strokeColor = UIColor(red: 244/255.0 , green: 71/255.0, blue: 140/255.0, alpha: 0.4)
        circle.isMask = false
        circle.identifier = 1
        mapView.addCircle(circle)

        //adds a masked circle on the map with solid border
        let maskedCircle: SKCircle = SKCircle()
        maskedCircle.centerCoordinate = CLLocationCoordinate2DMake(52.5233 - 0.002, 13.4127 + 0.002)
        maskedCircle.radius = 100;
        maskedCircle.fillColor = UIColor(red: 255/255.0 , green: 117/255.0, blue: 15/255.0, alpha: 0.5)
        maskedCircle.strokeColor = UIColor(red: 255/255.0 , green: 117/255.0, blue: 15/255.0, alpha: 0.8)
        maskedCircle.borderWidth = 5
        maskedCircle.isMask = true
        maskedCircle.maskedObjectScale = 3
        maskedCircle.identifier = 2
        mapView.addCircle(maskedCircle)
    }
    
    private func addPolygons()
    {
        //adding a masked triangle overlay without border
        let triangleVertexCoordinate1: CLLocation = CLLocation(latitude: 52.5233 + 0.002, longitude: 13.4127 + 0.002)
        let triangleVertexCoordinate2: CLLocation = CLLocation(latitude: 52.5233 + 0.0028, longitude: 13.4127 + 0.0025)
        let triangleVertexCoordinate3: CLLocation = CLLocation(latitude: 52.5233 + 0.002, longitude: 13.4127 + 0.003)
        let polygonCoordinates: Array<CLLocation> = [triangleVertexCoordinate1, triangleVertexCoordinate2, triangleVertexCoordinate3]
        
        let triangle: SKPolygon = SKPolygon()
        triangle.coordinates = polygonCoordinates
        triangle.fillColor = UIColor(red: 39/255.0 , green: 222/255.0, blue: 61/255.0, alpha: 0.5)
        triangle.borderWidth = 5
        triangle.isMask = true
        triangle.maskedObjectScale = 5
        triangle.identifier = 3
        mapView.addPolygon(triangle)
        
        //add a rhombus overlay with dotted border
        let rhombusVertexCoordinate1: CLLocation = CLLocation(latitude: 52.5233 + 0.002, longitude: 13.4127 - 0.0035)
        let rhombusVertexCoordinate2: CLLocation = CLLocation(latitude: 52.5233, longitude: 13.4127 - 0.005)
        let rhombusVertexCoordinate3: CLLocation = CLLocation(latitude: 52.5233 - 0.002, longitude: 13.4127 - 0.0035)
        let rhombusVertexCoordinate4: CLLocation = CLLocation(latitude: 52.5233, longitude: 13.4127 - 0.001)
        let maskedPolygonCoordinates: Array<CLLocation> = [rhombusVertexCoordinate1, rhombusVertexCoordinate2, rhombusVertexCoordinate3, rhombusVertexCoordinate4]
        
        let rhombus: SKPolygon = SKPolygon()
        rhombus.coordinates = maskedPolygonCoordinates
        rhombus.fillColor = UIColor(red: 65/255.0 , green: 145/255.0, blue: 255/255.0, alpha: 0.5)
        rhombus.strokeColor = UIColor(red: 65/255.0 , green: 145/255.0, blue: 255/255.0, alpha: 0.8)
        rhombus.borderWidth = 5
        rhombus.borderDotsSize = 20
        rhombus.borderDotsSpacingSize = 5
        rhombus.isMask = false
        rhombus.identifier = 4
        mapView.addPolygon(rhombus)
    }
    
    private func addPolylines()
    {
        let polylineCoordinate1: CLLocation = CLLocation(latitude: 52.5233 + 0.004, longitude: 13.4127 + 0.004)
        let polylineCoordinate2: CLLocation = CLLocation(latitude: 52.5233 + 0.0055, longitude: 13.4127 + 0.0051)
        let polylineCoordinate3: CLLocation = CLLocation(latitude: 52.5233 + 0.003, longitude: 13.4127 + 0.00521)
        let polylineCoordinates: Array<CLLocation> = [polylineCoordinate1,polylineCoordinate2,polylineCoordinate3]
        
        let polyLine: SKPolyline = SKPolyline()
        polyLine.coordinates = polylineCoordinates
        polyLine.fillColor = UIColor.redColor()
        polyLine.lineWidth = 10
        polyLine.identifier = 5
        mapView.addPolyline(polyLine)
    }
    
}