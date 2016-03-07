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
    var player = MPMusicPlayerController.applicationMusicPlayer()
    var itemCollection: MPMediaItemCollection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemCollection = MPMediaItemCollection(items: [self.mediaItem!])
        player.setQueueWithItemCollection(itemCollection!)
        
        
    }
    
    
    
}
