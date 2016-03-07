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

    
    var player = MPMusicPlayerController.applicationMusicPlayer()
    var itemCollection: MPMediaItemCollection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemCollection = MPMediaItemCollection(items: [self.mediaItem!])
        player.setQueueWithItemCollection(itemCollection!)
        
        let imageSize = CGSize(width: albumArt.bounds.width, height: albumArt.bounds.width)
        albumArt.image = self.mediaItem!.artwork!.imageWithSize(imageSize)
        
        songTitle.text = self.item!.titleForTableDisplay()
        artist.text = self.item!.subtitleForTableDisplay()
    }
    
    
    
}
