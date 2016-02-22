//
//  PreferenceSetType.swift
//  PreferencePicker
//
//  Created by Kevin Connor on 2/19/16.
//  Copyright © 2016 Kevin Connor. All rights reserved.
//

import Foundation

class PreferenceSetType {
    var importable: Bool = true
    var creatable: Bool = false
    var description: String
    var id: String
    
    init(id: String, description: String) {
        self.id = id
        self.description = description
    }
}