//
//  AnnotationsViewController.swift
//  SKMapsSwiftDemo
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

import Foundation
import SKMaps

class AnnotationsViewController: UIViewController, SKMapViewDelegate, SKCalloutViewDelegate {
    
    var mapView: SKMapView!
    var annotation1: SKAnnotation!
    var annotation3: SKAnnotation!
    var viewAnnotation: SKAnnotation!
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = SKMapView(frame: CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)))
        mapView.delegate = self
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.view.addSubview(self.mapView)
        
        let region: SKCoordinateRegion = SKCoordinateRegion(center: CLLocationCoordinate2DMake(52.5233, 13.4127), zoomLevel: 17)
        mapView.visibleRegion = region
        
        self.addAnnotations()
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        mapView.clearAllAnnotations()
    }
    
    //MARK: UI Adding
    
    private func addAnnotations() {
        
        self.mapView.calloutView.delegate = self
        let animationSettings: SKAnimationSettings = SKAnimationSettings()
        
        annotation1 = SKAnnotation()
        annotation1.identifier = 10
        annotation1.annotationType = SKAnnotationType.Purple
        annotation1.location = CLLocationCoordinate2DMake(52.5237, 13.4137)
        
        self.mapView.addAnnotation(annotation1, withAnimationSettings: animationSettings)
        
        annotation3 = SKAnnotation()
        annotation3.identifier = 13
        annotation3.annotationType = SKAnnotationType.Green
        annotation3.location = CLLocationCoordinate2DMake(52.5239, 13.4117)
        
        self.mapView.addAnnotation(annotation3, withAnimationSettings: animationSettings)
        self.mapView.showCalloutForAnnotation(annotation3, withOffset: CGPointMake(0, 42), animated: true)
        
        //Annotation with view
        //create our view
        let coloredView: UIImageView =  UIImageView(frame:CGRectMake(0.0, 0.0, 64.0, 64.0))
        coloredView.backgroundColor = UIColor.redColor()
        coloredView.image = UIImage(named: "picture")
        coloredView.contentMode = UIViewContentMode.Top
        coloredView.layer.cornerRadius = 10.0
        
        //add a label to our view
        let label: UILabel = UILabel(frame:CGRectMake(3.0, coloredView.frame.size.height - 40.0, coloredView.frame.size.width - 6.0, 40.0))
        label.text = "Custom view annotation"
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.textAlignment = NSTextAlignment.Center
        label.backgroundColor = UIColor.clearColor()
        label.font = UIFont.systemFontOfSize(15.0)
        coloredView.addSubview(label)
        
        //create the SKAnnotationView
        let view: SKAnnotationView = SKAnnotationView(view: coloredView, reuseIdentifier: "viewID")
        
        //create the annotation
        viewAnnotation = SKAnnotation()
        //set the custom view
        viewAnnotation.annotationView = view
        viewAnnotation.identifier = 100
        viewAnnotation.location = CLLocationCoordinate2DMake(52.5240, 13.4107)
        
        self.mapView.addAnnotation(viewAnnotation, withAnimationSettings: animationSettings)

    }
    
    //MARK: SKMapViewDelegate
    
    func mapView(mapView: SKMapView!, didSelectAnnotation annotation: SKAnnotation!) {
        
        let calloutOffset: CGPoint = CGPointMake(0, 42.0)
        
        mapView.showCalloutForAnnotation(annotation, withOffset: calloutOffset, animated: true)
    }
    
    func mapView(mapView: SKMapView!, calloutViewForAnnotation annotation: SKAnnotation!) -> UIView! {
        //Custom callouts.
        if annotation.identifier == annotation1.identifier
        {
            let view: UIView = UIView(frame: CGRectMake(0.0, 0.0, 200.0, 50.0))
            view.backgroundColor = UIColor.purpleColor()
            view.alpha = 0.5
            return view
        }

        return nil // Default callout view will be used.
        
    }
    
    func mapView(mapView: SKMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        mapView.hideCallout()
    }
    
    //MARK: SKCalloutViewDelegate
    
    func calloutView(calloutView: SKCalloutView!, didTapLeftButton leftButton: UIButton!) {
        print("Did tap left button on callout view.")
    }
    
    func calloutView(calloutView: SKCalloutView!, didTapRightButton rightButton: UIButton!) {
        print("Did tap right button on callout view.")
    }
}
