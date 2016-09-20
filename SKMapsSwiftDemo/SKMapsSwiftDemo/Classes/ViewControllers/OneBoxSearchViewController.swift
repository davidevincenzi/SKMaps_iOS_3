//
//  OneBoxSearchViewController.swift
//  SKMapsSwiftDemo
//
//  Copyright © 2016 skobbler. All rights reserved.
//

import UIKit
import SKMaps

class OneBoxSearchViewController: UIViewController, SKOneBoxViewControllerDelegate, SKPositionerServiceDelegate {
    
    var oneBoxBaseViewController: UINavigationController?
    var oneBoxViewController: SKOneBoxViewController?
    var searchBar: SKOneBoxSearchBar?
    var searchBarHolderView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.createOneBoxSearch()
        self.setupOneBoxLocation()
    }
    
    //MARK:- UI
    
    private func createOneBoxSearch() {
        self.createSearchBar()
        
        self.oneBoxViewController = SKOneBoxViewController(searchBar: self.searchBar!, searchProviders: self.searchProviders())
        self.oneBoxViewController?.modalTransitionStyle = .CrossDissolve
        self.oneBoxViewController?.delegate = self
        
        self.oneBoxBaseViewController = UINavigationController(rootViewController: self.oneBoxViewController!)
        self.oneBoxBaseViewController?.navigationBar.translucent = false
    }
    
    private func createSearchBar() {
        let path = NSBundle.mainBundle().pathForResource("SKOneBoxSearchBundle", ofType: "bundle")
        
        guard let safePath = path else {
            return
        }
        guard let bundle = NSBundle(path: safePath) else {
            return
        }
        
        let closeImage = UIImage(contentsOfFile: bundle.pathForResource("icon_clear_white", ofType: "png")!)!
        let clearImage = UIImage(contentsOfFile: bundle.pathForResource("icon_clear_grey", ofType: "png")!)!
        let closeImageAlpha = UIImage(contentsOfFile: bundle.pathForResource("icon_clear_white_alpha", ofType: "png")!)!
        
        self.searchBar = SKOneBoxSearchBar(frame: CGRectMake(0, 0, self.view.frame.width, 32.0), normalClearImage: closeImageAlpha, highlightedClearImage: closeImage, inactiveSearchClearImage: clearImage, searchImage: nil)
        self.searchBar?.autoresizingMask = .FlexibleWidth
        self.searchBar?.shouldShowSearchDot = false
        self.searchBar?.placeHolder = NSAttributedString(string: "Search text here")
        
        self.searchBarHolderView = UIView(frame: CGRectMake(0.0, 20.0, self.searchBar!.frame.width, self.searchBar!.frame.height))
        self.searchBarHolderView?.backgroundColor = UIColor.lightGrayColor()
        
        if let holderView = self.searchBarHolderView {
            self.view.addSubview(holderView)
        }
        
        self.repositionSearchBar()
    }
    
    private func repositionSearchBar() {
        self.searchBar?.frame = CGRectMake(0.0, 0.0, self.searchBarHolderView?.frame.size.width ?? 0, self.searchBar?.frame.size.height ?? 0)
        self.searchBar?.removeFromSuperview()
        
        if let safeSearchBar = self.searchBar {
            self.searchBarHolderView?.addSubview(safeSearchBar)
        }
    }
    
    //MARK:- SKOneBoxViewControllerDelegate
    
    func oneBoxViewController(viewController: SKOneBoxBaseViewController, searchBarDidClear searchBar: SKOneBoxSearchBar) {
        
    }
    
    func oneBoxViewController(viewController: SKOneBoxBaseViewController, searchBarTextDidBeginEditing searchBar:SKOneBoxSearchBar) {
        self.presentViewController(self.oneBoxBaseViewController!, animated: true) {
            searchBar.showKeyboard()
        }
    }
    
    func oneBoxViewController(viewController: SKOneBoxBaseViewController!, didSelectSearchResult searchResult:SKOneBoxSearchResult!, fromResultList array: [AnyObject]!) {
        
    }
    
    func didDismissOneBoxViewController(viewController: SKOneBoxBaseViewController) {
        
    }
    
    func willDismissOneBoxViewController(viewController: SKOneBoxBaseViewController) {
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: false)
        self.repositionSearchBar()
    }
    
    func willShowOneBoxViewController(viewController: SKOneBoxBaseViewController) {
        
    }
    
    //MARK:- Location services
    
    private func setupOneBoxLocation() {
        SKPositionerService.sharedInstance().startLocationUpdate()
        SKPositionerService.sharedInstance().delegate = self
    }
    
    //MARK: SKPositionerServiceDelegate
    
    func positionerService(positionerService: SKPositionerService!, updatedCurrentLocation currentLocation: CLLocation!) {
        SKOneBoxSearchPositionerService.sharedInstance().reportLocation(currentLocation)
    }
    
    //MARK:- Search Providers
    
    private func searchProviders() -> [SKSearchBaseProvider] {
        let mapsSearchProvider = MapsSearchProvider(APIKey: "", apiSecret: "")
        mapsSearchProvider.providerID = 0
        
        let appleSearchProvider = AppleSearchProvider(APIKey: "", apiSecret: "")
        appleSearchProvider.providerID = 1
        
        return [mapsSearchProvider, appleSearchProvider]
    }
}
