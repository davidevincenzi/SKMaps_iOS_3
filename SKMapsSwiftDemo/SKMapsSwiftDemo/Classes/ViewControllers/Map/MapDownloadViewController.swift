//
//  MapDownloadViewController.swift
//  SKMapsSwiftDemo
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

import Foundation
import SKMaps

let kMapDownloadFinished: String = "Download finished"

class MapDownloadViewController: UIViewController, SKTDownloadManagerDelegate, SKTDownloadManagerDataSource {
    
    var regionToDownload: SKTPackage!
    private var startButton: UIButton!
    private var progressView: UIProgressView!
    private var percentLabel: UILabel!
   
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addUI()
    }
    
    
    //MARK: UI
    
    private func addUI() {
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        let title: String = "Download: " + regionToDownload.nameForLanguageCode("en")
        
        startButton = UIButton(type:.System)
        startButton.frame = CGRectMake(80, 100, 200, 50)
        startButton.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        startButton.setTitle(title, forState: UIControlState.Normal)
        startButton.addTarget(self, action: #selector(MapDownloadViewController.startDownloading), forControlEvents: UIControlEvents.TouchUpInside)
        startButton.layer.cornerRadius = 15
        startButton.layer.borderWidth = 1
        self.view.addSubview(startButton)
        
        progressView = UIProgressView(frame: CGRectMake(30, CGRectGetMaxY(startButton.frame) + 40, CGRectGetWidth(self.view.frame) - 60, 20))
        progressView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        progressView.progress = 0
        self.view.addSubview(progressView)
        
        percentLabel = UILabel(frame: CGRectMake(30, CGRectGetMaxY(progressView.frame) + 20, 200, 20))
        percentLabel.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        percentLabel.text = "0"
        self.view.addSubview(percentLabel)
    }
    
    internal func startDownloading() {
        let region: SKTDownloadObjectHelper =  SKTDownloadObjectHelper.downloadObjectHelperWithSKTPackage(regionToDownload) as! SKTDownloadObjectHelper
        SKTDownloadManager.sharedInstance().requestDownloads([region], startAutomatically: true, withDelegate: self, withDataSource: self)
    }
    
    //MARK: SKTDownloadManagerDelegate
    
    func downloadManager(downloadManager: SKTDownloadManager, saveDownloadHelperToDatabase downloadHelper: SKTDownloadObjectHelper) {
        let path: String = (SKTDownloadManager.libraryDirectory() as NSString).stringByAppendingPathComponent(downloadHelper.getCode())
        let code: String = downloadHelper.getCode()
        
        SKMapsService.sharedInstance().packagesManager.addOfflineMapPackageNamed(code, inContainingFolderPath: path)
        
        let fman: NSFileManager = NSFileManager()
        do {
            try fman.removeItemAtPath(path)
        } catch {
            
        }
    }
    
    func notEnoughDiskSpace() {
        print("not enough space")
    }
    
    func downloadManager(downloadManager: SKTDownloadManager, didUpdateCurrentDownloadProgress  currentPorgressString: String, currentDownloadPercentage currentPercentage: Float, overallDownloadProgress overallProgressString: String, overallDownloadPercentage overallPercentage: Float, forDownloadHelper downloadHelper: SKTDownloadObjectHelper) {
        progressView.progress = overallPercentage / 100
        percentLabel.text = overallProgressString
    }
    
    func downloadManager(downloadManager: SKTDownloadManager, didUpdateUnzipProgress progressString: String, percentage currentPercentage: Float, forDownloadHelper downloadHelper: SKTDownloadObjectHelper) {
        progressView.progress = currentPercentage / 100
        percentLabel.text = progressString
    }
    
    func downloadManager(downloadManager: SKTDownloadManager, didDownloadDownloadHelper downloadHelper: SKTDownloadObjectHelper, withSuccess success: Bool) {
        print("didDownloadDownloadHelper")
        
        startButton.enabled = false
        
        progressView.progress = 1
        percentLabel.text = "Download finished"
    }
    
    func didCancelDownload() {
        startButton.enabled = true
    }
    
    func downloadManager(downloadManager: SKTDownloadManager, didPauseDownloadForDownloadHelper downloadHelper: SKTDownloadObjectHelper) {
        print("didPauseDownloadForDownloadHelper")
        startButton.enabled = true
    }
    
    func downloadManager(downloadManager: SKTDownloadManager, didResumeDownloadForDownloadHelper downloadHelper: SKTDownloadObjectHelper) {
        print("didResumeDownloadForDownloadHelper")
        startButton.enabled = false
    }
    
    //MARK: SKTDownloadManagerDataSource
    
    func isOnBoardMode() -> Bool {
        return false
    }
    
}