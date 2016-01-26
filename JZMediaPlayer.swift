//
//  JZMediaPlayer.swift
//  Syrinx
//
//  Created by Joey Zhou on 1/26/16.
//  Copyright © 2016 Dev Branch, Inc. All rights reserved.
//

import UIKit
import MediaPlayer
import AwesomeCache

class JZMediaPlayer: NSObject {
    
    var player = MPMusicPlayerController.systemMusicPlayer()
    var testForMusicPlayingTimer: NSTimer!
    var currentMediaIndex: Int!
    var currentTimestamp: NSTimeInterval!
    var mediaCollection: MPMediaItemCollection!
    
    class var sharedInstance: JZMediaPlayer {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: JZMediaPlayer? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = JZMediaPlayer()
        }
        return Static.instance!
    }
    
    // MARK: Basic start/stop
    func startPlayer() {
        player.setQueueWithItemCollection(mediaCollection)
        
        // set current item if it's not nil
        if currentMediaIndex != nil {
            player.nowPlayingItem = mediaCollection.items[currentMediaIndex]
        }
        
        if currentTimestamp != nil {
            player.currentPlaybackTime = currentTimestamp
        }
        
        player.play()
        
        // hack to make sure player is playing
        testForMusicPlayingTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(1), target: self, selector: "testForMusicPlaying", userInfo: nil, repeats: false)
    }
    
    func stopPlayer() {
        player.pause()
        
        // cache
        currentMediaIndex = player.indexOfNowPlayingItem
        currentTimestamp = player.currentPlaybackTime
        
        saveMediaPlayer()
    }
    
    // MARK: Persistance layer
    func saveMediaPlayer() {
        // set timestamp
        currentTimestamp = player.currentPlaybackTime
        
        // save
        do {
            let cache = try Cache<NSString>(name:"cache")
            print("Saving:")
            print("CurrentIndex: \(currentMediaIndex.description)")
            print("CurrentTimestamp: \(currentTimestamp.description)")
            cache["currentMediaIndex"] = currentMediaIndex.description
            cache["currentIndex"] = currentMediaIndex.description
            print("Saved player to disk.")
        } catch _ {
            print("Something went wrong with AwesomeCache")
        }
    }
    
    func loadMediaPlayer() {
        
        do {
            let cache = try Cache<NSString>(name:"cache")
            currentTimestamp = cache["currentTimestamp"]?.doubleValue
            currentMediaIndex = cache["currentMediaIndex"]?.integerValue
            print("CurrentIndex: \(currentMediaIndex.description)")
            print("CurrentTimestamp: \(currentTimestamp.description)")
            
            print("Loaded player to disk.")
        } catch _ {
            print("Something went wrong with AwesomeCache")
        }
    }
    
    // MARK: Hack for player.play()
    func testForMusicPlaying()
    {
        if player.playbackState != .Playing
        {
            testForMusicPlayingTimer.invalidate()
            
            player = MPMusicPlayerController.applicationMusicPlayer()
            
            player.setQueueWithItemCollection(mediaCollection)
            
            // set current item if it's not nil
            if currentMediaIndex != nil {
                player.nowPlayingItem = mediaCollection.items[currentMediaIndex]
            }
            
            if currentTimestamp != nil {
                player.currentPlaybackTime = currentTimestamp
            }
            
            player.play()
            
            testForMusicPlayingTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(1), target: self, selector: "testForMusicPlaying", userInfo: nil, repeats: false)
        }
        else
        {
            if let title = player.nowPlayingItem?.title{
                print("Current song: \(title)\nCurrent time:\(player.currentPlaybackTime)")
            }
            testForMusicPlayingTimer.invalidate()
        }
    }
    
}
