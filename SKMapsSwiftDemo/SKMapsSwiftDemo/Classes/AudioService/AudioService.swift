//
//  AudioService.swift
//  SKMapsSwiftDemo
//
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

import Foundation
import AVFoundation
import AudioToolbox

private let _AudioServiceSharedInstance = AudioService()

class AudioService: NSObject, AVAudioPlayerDelegate {
    
    var audioPlayer: AVAudioPlayer!
    var audioFilesArray: Array<String>!
    var audioFilesFolderPath: String!
    var volume: Float = AVAudioSession.sharedInstance().outputVolume
    
    //MARK: Lifecycle
    
    class func sharedInstance() -> AudioService {
        return _AudioServiceSharedInstance
    }
    
    override init() {
        audioPlayer = nil
        audioFilesArray = Array()
        audioFilesFolderPath = ""
    }
    
    deinit {
        audioPlayer.delegate = nil
    }

    //MARK: Public methods
    
    func play(audioFiles: Array<String>) {
        objc_sync_enter(self)
        
        let mainBundlePath: String = NSBundle.mainBundle().resourcePath! + ("/SKAdvisorResources.bundle")
        let advisorResourcesBundle: NSBundle? =  NSBundle(path:mainBundlePath)
        
        if advisorResourcesBundle == nil
        {
           print("Advisor resources not found.")
            return
        }
        
        if audioFiles.count == 0
        {
            print("No audio files to play.")
            return
        }
        
        audioFilesArray = audioFilesArray + audioFiles
        
        if audioFilesArray.count > 0 && audioPlayer == nil
        {
            let audioFileName: String = audioFilesArray[0]
            self.playAudioFile(audioFileName)
            audioFilesArray.removeAtIndex(0)
        }

        objc_sync_exit(self)
    }
    
    func playAudioFile(audioFileName: String) {
        var soundFilePath: String = audioFilesFolderPath + "/" + audioFileName
        soundFilePath = soundFilePath + ".mp3"
        
        if  !NSFileManager.defaultManager().fileExistsAtPath(soundFilePath)
        {
            return
        }
        else
        {
            audioPlayer = try? AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: soundFilePath), fileTypeHint: nil)
            audioPlayer.delegate = self
            audioPlayer.play()
        }

    }
    
    func cancel() {
        if audioPlayer != nil {
            audioPlayer.stop()
            audioPlayer.delegate = nil
            audioPlayer = nil
        }
        
        audioFilesArray.removeAll(keepCapacity: false)
    }
    
    //MARK: AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        if audioFilesArray.count > 0
        {
            let audioFileName: String = audioFilesArray[0]
            self.playAudioFile(audioFileName)
            audioFilesArray.removeAtIndex(0)
        }
        else
        {
            self.cancel()
        }

    }
    
}