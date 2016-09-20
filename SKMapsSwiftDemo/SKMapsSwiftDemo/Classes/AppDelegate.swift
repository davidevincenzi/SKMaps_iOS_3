//
//  AppDelegate.swift
//  SKMapsSwiftDemo
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

import UIKit
import SKMaps

let API_KEY: String = ""

@UIApplicationMain
class AppDelegate: NSObject, UIApplicationDelegate, SKMapVersioningDelegate {

    var window: UIWindow?
    var rootViewController: RootViewController!
    var cachedMapRegions: Array<MapRegion>!
    var skMapsObject: SKTMapsObject?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
    
        
        let initSettings: SKMapsInitSettings = SKMapsInitSettings()
        initSettings.mapDetailLevel = .Full
        initSettings.connectivityMode = .Online
        
        
        print(initSettings.cachesPath)
        SKMapsService.sharedInstance().initializeSKMapsWithAPIKey("", settings: initSettings)
        SKPositionerService.sharedInstance().startLocationUpdate()
        SKMapsService.sharedInstance().mapsVersioningManager.delegate = self
        
        SKTDownloadManager.sharedInstance()
        cachedMapRegions = Array<MapRegion>()
        
        self.rootViewController = RootViewController()
        let navigationController: UINavigationController = UINavigationController(rootViewController: self.rootViewController)
        navigationController.navigationBar.translucent = false
        navigationController.interactivePopGestureRecognizer!.enabled = false
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        if let window = self.window {
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
                
        return true
    }
    
    //MARK: SKMapVersioningDelegate
    
    func mapsVersioningManager(versioningManager: SKMapsVersioningManager!, detectedNewAvailableMapVersion latestMapVersion: String!, currentMapVersion: String!) {
        print("Current map version: " + currentMapVersion + " \n Latest map version: " + latestMapVersion)
        
        let message: String? = "A new map version is available on the server: " + latestMapVersion + "\n Current map version: " + currentMapVersion
        
        dispatch_async(dispatch_get_main_queue()) {
            let alert = UIAlertController(title: "New map version available", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Update", style:  UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) -> Void in
                let availableVersions: Array = SKMapsService.sharedInstance().mapsVersioningManager.availableMapVersions as! Array<SKVersionInformation>
                let latestVersion = availableVersions[0]
                SKMapsService.sharedInstance().mapsVersioningManager.updateToVersion(latestVersion.version)
            }))
            
            self.rootViewController.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    func mapsVersioningManager(versioningManager: SKMapsVersioningManager!, loadedWithMapVersion currentMapVersion: String!) {
        print("Map version file download finished.\n")
        //needs to be updated for a new map version
        MapJSONParser.sharedInstance().downloadAndParseJSON()
    }
    
    func mapsVersioningManager(versioningManager: SKMapsVersioningManager!, loadedWithOfflinePackages packages: [AnyObject]!, updatablePackages: [AnyObject]!) {
        print(String(updatablePackages.count) + " updatable packages")
        for package: SKMapPackage in updatablePackages as! Array<SKMapPackage>
        {
            print(package.name)
        }
    }
    
    
    
}

