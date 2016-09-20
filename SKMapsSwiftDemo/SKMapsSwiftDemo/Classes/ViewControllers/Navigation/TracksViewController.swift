//
//  TracksViewController.swift
//  SKMapsSwiftDemo
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

import Foundation

private var showGPxWarning: Bool = true

class TracksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var dataSource: Array<String>!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if showGPxWarning
        {
            let message: String? = "GPX track navigation is available for commercial use with a enterprise license. Usage without such a license will lead to your API KEY being suspended."
            let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
            showGPxWarning = false
        }
        
        let tracksTableView: UITableView = UITableView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        tracksTableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight];
        tracksTableView.delegate = self;
        tracksTableView.dataSource = self;
        self.view.addSubview(tracksTableView)
        
        dataSource = Array()
        
        let bundlePath: String = NSBundle.mainBundle().resourcePath!
        let dirContents: Array? = try? NSFileManager.defaultManager().contentsOfDirectoryAtPath(bundlePath)
        for fileName: String in dirContents!
        {
            let string: NSString = fileName;
            if string.pathExtension == "gpx"
            {
                dataSource.append(string.stringByDeletingPathExtension)
            }
            
        }
    }
    
    // MARK: UITableViewDatasource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier: String? = "cellIdentifier"
        var cell:UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier!)
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        
        cell!.selectionStyle = UITableViewCellSelectionStyle.None
        cell!.textLabel!.text = dataSource[indexPath.row]
        
        return cell!
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tracksVC: GPSFilesViewControler = GPSFilesViewControler(fileName: dataSource[indexPath.row])
        self.navigationController?.pushViewController(tracksVC, animated: true)
    }
    
}