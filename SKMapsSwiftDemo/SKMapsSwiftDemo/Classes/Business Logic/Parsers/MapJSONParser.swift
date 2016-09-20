//
//  MapJSONParser.swift
//  SKMapsSwiftDemo
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

import Foundation
import SKMaps

let kParsingFinishedNotificationName = "JSONParsingFinishedNotification"
private let _MapJSONParser = MapJSONParser()

class MapJSONParser: NSObject, NSURLConnectionDataDelegate {
    
    var isParsingFinished: Bool = false
    var jsonData: NSMutableData!
    var jsonConnection: NSURLConnection!
    
    class func sharedInstance() -> MapJSONParser {
        return _MapJSONParser
    }
    
    func downloadAndParseJSON() {
        jsonData = NSMutableData()
        let jsonURLString = SKMapsService.sharedInstance().packagesManager.mapsJSONURLForVersion(nil)
        let jsonURL = NSURL(string: jsonURLString)
        let jsonRequest = NSURLRequest(URL: jsonURL!);
        jsonConnection = NSURLConnection(request: jsonRequest, delegate: self)
    }
    
  
    //MARK: NSURLConnectionDataDelegate
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        if data.length > 0 {
            jsonData.appendData(data)
        }
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        self.parseJSON()
    }
    
    func parseJSON() {
        let jsonString: String =  NSString(data: jsonData, encoding:NSUTF8StringEncoding)! as String
     //   String.stringWithBytesNoCopy(jsonData.bytes, length: jsonData.length, encoding:NSUTF8StringEncoding , freeWhenDone: false)
        let skMaps: SKTMapsObject = SKTMapsObject.convertFromJSON(jsonString)
        
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.skMapsObject = skMaps
        
        isParsingFinished = true
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kParsingFinishedNotificationName, object: nil))
    }
}