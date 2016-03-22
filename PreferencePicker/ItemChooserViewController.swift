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
    var mediaItem: MPMediaItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mediaItem = item!.mediaItem
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

class iTunesItemChooserViewController : ItemChooserViewController {
    @IBOutlet weak var albumArt: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBAction func playPause(sender: UIButton) {
        self.playPause()
    }
    
    
    var player: MPMusicPlayerController?
    var itemCollection: MPMediaItemCollection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player = MPMusicPlayerController.applicationMusicPlayer()

        
        let imageSize = CGSize(width: albumArt.bounds.width, height: albumArt.bounds.width)
        if let artwork = self.mediaItem!.artwork {
            albumArt.image = artwork.imageWithSize(imageSize)
        }
        songTitle.text = self.item!.titleForTableDisplay()
        artist.text = self.item!.subtitleForTableDisplay()
    }
    
    func playPause() {
        // have to share applicationMusicPlayer with other ItemChoosers
        var myItemLoaded = true
        if player!.nowPlayingItem != self.mediaItem {
            itemCollection = MPMediaItemCollection(items: [self.mediaItem!])
            player!.setQueueWithItemCollection(itemCollection!)
            myItemLoaded = false
        }
        switch player!.playbackState {
        case .Stopped, .Paused:
            player!.play()
        case .Playing:
            if myItemLoaded {
                player!.pause()
            } else {
                player!.play()
            }
        default: break
        }
    }
    
}
