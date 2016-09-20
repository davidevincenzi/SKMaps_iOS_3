//
//  MenuView.swift
//  SKMapsSwiftDemo
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

import Foundation

class MenuView: UIView {

    var menuButton: UIButton!
    var positionSelect: UISegmentedControl!
    var navigateButton: UIButton!
    var freeDriveButton: UIButton!
    var cancelButton: UIButton!
    var settingsButton: UIButton!
    var plusButton: UIButton!
    var minusButton: UIButton!
    var styleButton: UIButton!
    var navigationStyle: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addButtons()
        self.showNavigationStyleUI(false)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let hitView: UIView? = super.hitTest(point, withEvent: event)
        if hitView == self {
            return nil
        }
        
        return hitView
    }
    
    func showNavigationStyleUI(navigatioStyle: Bool) {
        if (navigationStyle) {
            cancelButton.hidden = false
            plusButton.hidden = false
            minusButton.hidden = false
            styleButton.hidden = false
            navigateButton.hidden = true
            freeDriveButton.hidden = true
            positionSelect.hidden = true
            settingsButton.hidden = true
            cancelButton.frameY = 0.0
            styleButton.frameY = cancelButton.frameMaxY + 1.0
            plusButton.frameY = styleButton.frameMaxY + 1.0
            minusButton.frameY = styleButton.frameMaxY + 1.0
        } else {
            cancelButton.hidden = true
            plusButton.hidden = true
            minusButton.hidden = true
            navigateButton.hidden = false
            freeDriveButton.hidden = false
            positionSelect.hidden = false
            settingsButton.hidden = false
            styleButton.hidden = true
            positionSelect.frameY = 0.0
            navigateButton.frameY = positionSelect.frameMaxY + 1.0
            freeDriveButton.frameY = navigateButton.frameMaxY + 1.0
            settingsButton.frameY = freeDriveButton.frameMaxY + 1.0
        }
        
    }
    
    func addButtons() {
        let sizeMultiplier: CGFloat = UIDevice.isiPad() ? 2.0 : 1.0
        menuButton = UIButton(type:.Custom)
        menuButton.tintColor = UIColor.brownColor()
        menuButton.setTitle("<", forState: UIControlState.Normal)
        menuButton.frame = CGRectMake(120.0 * sizeMultiplier, 0.0, 50.0, 50.0)
        menuButton.tag = 1
        self.addSubview(menuButton)
        
        positionSelect = UISegmentedControl(frame: CGRectMake(0.0, 0.0, 120.0 * sizeMultiplier, 40.0 * sizeMultiplier))
        positionSelect.insertSegmentWithTitle("Select start point", atIndex: 0, animated: false)
        positionSelect.insertSegmentWithTitle("Select end point", atIndex: 1, animated: false)
        
        for segment: AnyObject in positionSelect.subviews {
            for label: AnyObject in segment.subviews {
                if label.isKindOfClass(UILabel.self) {
                    let actualLabel: UILabel = label as! UILabel
                    actualLabel.adjustsFontSizeToFitWidth = true
                    actualLabel.numberOfLines = 2
                }
            }
        }
        
        positionSelect.backgroundColor = UIColor(white: 1.0, alpha: 0.6)
        positionSelect.selectedSegmentIndex = 1
        self.addSubview(positionSelect)
        
        navigateButton = UIButton(type:.System)
        navigateButton.backgroundColor = UIColor(white: 1.0, alpha: 0.6)
        navigateButton.setTitle("Calculate route(s)", forState: UIControlState.Normal)
        navigateButton.titleLabel!.textColor = UIColor.blackColor()
        navigateButton.frame = CGRectMake(0.0, positionSelect.frameMaxY, 120.0 * sizeMultiplier, 40.0 * sizeMultiplier)
        self.addSubview(navigateButton)
        
        freeDriveButton = UIButton(type:.System)
        freeDriveButton.backgroundColor = UIColor(white: 1.0, alpha: 0.6)
        freeDriveButton.setTitle("Start free drive", forState: UIControlState.Normal)
        freeDriveButton.titleLabel!.textColor = UIColor.blackColor()
        freeDriveButton.frame = CGRectMake(0.0, navigateButton.frameMaxY, 120.0 * sizeMultiplier, 40.0 * sizeMultiplier)
        self.addSubview(freeDriveButton)
        
        cancelButton = UIButton(type:.System)
        cancelButton.backgroundColor = UIColor(white: 1.0, alpha: 0.6)
        cancelButton.setTitle("Stop", forState: UIControlState.Normal)
        cancelButton.titleLabel!.textColor = UIColor.blackColor()
        cancelButton.frame = CGRectMake(0.0, freeDriveButton.frameMaxY, 120.0 * sizeMultiplier, 40.0 * sizeMultiplier)
        self.addSubview(cancelButton)
        
        styleButton = UIButton(type:.System)
        styleButton.backgroundColor = UIColor(white: 1.0, alpha: 0.6)
        styleButton.setTitle("Change style", forState: UIControlState.Normal)
        styleButton.titleLabel!.textColor = UIColor.blackColor()
        styleButton.frame = CGRectMake(0.0, cancelButton.frameMaxY, 120.0 * sizeMultiplier, 40.0 * sizeMultiplier)
        self.addSubview(styleButton)
        
        settingsButton = UIButton(type:.System)
        settingsButton.backgroundColor = UIColor(white: 1.0, alpha: 0.6)
        settingsButton.setTitle("Change style", forState: UIControlState.Normal)
        settingsButton.titleLabel!.textColor = UIColor.blackColor()
        settingsButton.frame = CGRectMake(0.0, styleButton.frameMaxY, 120.0 * sizeMultiplier, 40.0 * sizeMultiplier)
        self.addSubview(settingsButton)
        
        plusButton = UIButton(type:.System)
        plusButton.backgroundColor = UIColor(white: 1.0, alpha: 0.6)
        plusButton.setTitle("Increase simulation speed", forState: UIControlState.Normal)
        plusButton.titleLabel!.textColor = UIColor.blackColor()
        plusButton.titleLabel?.adjustsFontSizeToFitWidth = true
        plusButton.titleLabel!.numberOfLines = 2
        plusButton.titleLabel!.textAlignment = NSTextAlignment.Center
        plusButton.frame = CGRectMake(0.0, positionSelect.frameMaxY, 60 * sizeMultiplier, 40.0 * sizeMultiplier)
        plusButton.tag = 1
        self.addSubview(plusButton)
        
        minusButton = UIButton(type: UIButtonType.System)
        minusButton.backgroundColor = UIColor(white: 1.0, alpha: 0.6)
        minusButton.setTitle("Decrease simulation speed", forState: UIControlState.Normal)
        minusButton.titleLabel!.textColor = UIColor.blackColor()
        minusButton.titleLabel?.adjustsFontSizeToFitWidth = true
        minusButton.titleLabel!.numberOfLines = 2
        minusButton.titleLabel!.textAlignment = NSTextAlignment.Center
        minusButton.frame = CGRectMake(60.0 * sizeMultiplier + 1.0, positionSelect.frameMaxY, 60 * sizeMultiplier - 1.0, 40.0 * sizeMultiplier)
        minusButton.tag = 1
        self.addSubview(minusButton)
    }
}