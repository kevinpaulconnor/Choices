//
//  ItemChooserViewController.swift
//  PreferencePicker
//
//  Created by Kevin Connor on 3/3/16.
//  Copyright © 2016 Kevin Connor. All rights reserved.
//

import UIKit
import MediaPlayer

class ItemChooserViewController: UIViewController {
    var item: PreferenceSetItem?
    
    //api for parent controller to inform ItemChooser
    // that it has lost control of a shared resource,
    // so that it can adjust its state if necessary
    func updateAfterLosingControl() {
        
    }
}

class iTunesItemChooserViewController : ItemChooserViewController {
    @IBOutlet weak var playerButton: UIButton!
    @IBOutlet weak var albumArt: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBAction func playPause(_ sender: UIButton) {
        self.playPause()
    }
    
    
    var player: MPMusicPlayerController?
    var itemCollection: MPMediaItemCollection?
    var mediaItem: MPMediaItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player = MPMusicPlayerController.applicationMusicPlayer
        mediaItem = item!.referenceItem.mediaItem
        
        let imageSize = CGSize(width: albumArt.bounds.width, height: albumArt.bounds.width)
        if let artwork = self.mediaItem!.artwork {
            albumArt.image = artwork.image(at: imageSize)
        }
        songTitle.text = self.item!.titleForTableDisplay()
        artist.text = self.item!.subtitleForTableDisplay()
    }
    
    override func updateAfterLosingControl() {
        if (player!.nowPlayingItem == self.mediaItem && player!.playbackState == .playing) {
            swapMyImage()
        }
    }
    
    func swapMyImage() {
        //FIXME it would be nice if a relevant control state applied here,
        //but it doesn't look like one does
        if (playerButton.currentImage == #imageLiteral(resourceName: "Play-play_solid")) {
            playerButton!.setImage(#imageLiteral(resourceName: "Play-stop_solid"), for: UIControl.State.normal)
        } else {
            playerButton!.setImage(#imageLiteral(resourceName: "Play-play_solid"), for: UIControl.State.normal)
        }
    }
    
    func playPause() {
        // have to share applicationMusicPlayer with other ItemChoosers
        var myItemLoaded = true
        if player!.nowPlayingItem != self.mediaItem {
            if let parent = self.parent as! ChoosePreferenceViewController! {
                    parent.itemChooserGrabbedControl(controllingItem: self)
            }
            itemCollection = MPMediaItemCollection(items: [self.mediaItem!])
            player!.setQueue(with: itemCollection!)
            myItemLoaded = false
        }
        swapMyImage()
        switch player!.playbackState {
        case .stopped, .paused:
            player!.play()
        case .playing:
            if myItemLoaded {
                player!.pause()
            } else {
                player!.play()
            }
        default: break
        }
    }
    
}
