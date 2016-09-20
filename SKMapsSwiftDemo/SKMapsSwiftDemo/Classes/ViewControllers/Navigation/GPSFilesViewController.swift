//
//  GPSFilesViewController.swift
//  SKMapsSwiftDemo
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

import Foundation
import SKMaps

enum GPSFileElements: Int
{
    case Collection = 1
    case Subcollection
    case Points
}

class GPSFilesViewControler: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var fileName: String!
    var type: GPSFileElements = GPSFileElements.Collection
    var tableView: UITableView!
    var datasource: Array<AnyObject>!
    
    //MARK: Lifecycle

    init(fileName: String) {
        super.init(nibName: nil, bundle: nil)
        self.fileName = fileName
    }
    
    init(type: GPSFileElements, datasource:Array<AnyObject>) {
        super.init(nibName: nil, bundle: nil)
        self.type = type
        self.datasource = datasource
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        
        self.populateTable()
    }
    
    //MARK: Private methods
    
    private func populateTable() {
        if datasource == nil
        {
            datasource = Array()
            let path: String = NSBundle.mainBundle().pathForResource(fileName, ofType: "gpx")!
            do {
                let root: SKGPSFileElement = try SKGPSFilesService.sharedInstance().loadFileAtPath(path)
                datasource = try? SKGPSFilesService.sharedInstance().childElementsForElement(root) as! Array<SKGPSFileElement>
            } catch {
                
            }

        }
    }
    
    private func stringForType(type: SKGPSFileElementType) -> String {
        var typeString: String = ""
        
        switch type {
        case SKGPSFileElementType.GPXRoot:
            typeString = "Root"
            
        case SKGPSFileElementType.GPXRoute:
            typeString = "Route"
            
        case SKGPSFileElementType.GPXRoutePoint:
            typeString = "RoutePoint"
            
        case SKGPSFileElementType.GPXTrack:
            typeString = "Track"
            
        case SKGPSFileElementType.GPXTrackSegment:
            typeString = "TrackSegment"
            
        case SKGPSFileElementType.GPXTrackPoint:
            typeString = "TrackPoint"
            
        case SKGPSFileElementType.GPXWaypoint:
            typeString = "Waypoint"
        }
        
        return typeString
    }
    
    func drawGPSCollection(sender: AnyObject, event: UIEvent) {
        let touches: NSSet = event.allTouches()!
        let touch: UITouch = touches.anyObject() as! UITouch
        let currentTouchPosition: CGPoint = touch.locationInView(tableView)
        let indexPath: NSIndexPath = tableView.indexPathForRowAtPoint(currentTouchPosition)!
        
        let gpsElement: SKGPSFileElement = datasource[indexPath.row] as! SKGPSFileElement
        let gpsDrawVC: GPSElementsDrawingViewController = GPSElementsDrawingViewController()
        gpsDrawVC.gpsElement = gpsElement
        self.navigationController?.pushViewController(gpsDrawVC, animated:true)
    }
    
    // MARK: UITableViewDatasource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier: String? = "cellIdentifier"
        var cell:UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier!)
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellIdentifier)
        }
        
        cell!.selectionStyle = UITableViewCellSelectionStyle.None
        cell!.accessoryView = nil
        
        if type.rawValue != GPSFileElements.Points.rawValue
        {
            let gpsElement: SKGPSFileElement = datasource[indexPath.row] as! SKGPSFileElement
            cell!.textLabel!.text = gpsElement.name
            cell!.detailTextLabel!.text = self.stringForType(gpsElement.type)
            
            if gpsElement.type == SKGPSFileElementType.GPXTrackSegment || gpsElement.type == SKGPSFileElementType.GPXRoute || gpsElement.type == SKGPSFileElementType.GPXTrack
            {
                let renderButton: UIButton = UIButton(type:.System)
                renderButton.setTitle("Draw", forState: UIControlState.Normal)
                renderButton.addTarget(self, action: #selector(GPSFilesViewControler.drawGPSCollection(_:event:)), forControlEvents: UIControlEvents.TouchUpInside)
                renderButton.frame = CGRectMake(0.0, 0.0, 50.0, 30.0)
                cell!.accessoryView = renderButton
            }
        }
        else
        {
            let point: CLLocation = datasource[indexPath.row] as! CLLocation
            cell!.textLabel!.text =  String(format: "(%.4f,%.4f)", arguments: [point.coordinate.latitude, point.coordinate.longitude])
        }
        
        
        return cell!
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if type.rawValue != GPSFileElements.Points.rawValue
        {
            let gpsElement: SKGPSFileElement = datasource[indexPath.row] as! SKGPSFileElement
            
            if type.rawValue == GPSFileElements.Collection.rawValue && gpsElement.type.rawValue == SKGPSFileElementType.GPXTrack.rawValue
            {
                do {
                    let children: Array<SKGPSFileElement>  = try SKGPSFilesService.sharedInstance().childElementsForElement(gpsElement) as! Array<SKGPSFileElement>
                    let subList: GPSFilesViewControler =  GPSFilesViewControler(type: GPSFileElements.Subcollection, datasource: children)
                    self.navigationController?.pushViewController(subList, animated:true)
                } catch {
                }
            }
            else
            {
                let points: Array<CLLocation> = SKGPSFilesService.sharedInstance().locationsForElement(gpsElement) as! Array<CLLocation>
                let pointsVC: GPSFilesViewControler =  GPSFilesViewControler(type: GPSFileElements.Points, datasource: points)
                self.navigationController?.pushViewController(pointsVC, animated:true)
            }
        }
    }

}