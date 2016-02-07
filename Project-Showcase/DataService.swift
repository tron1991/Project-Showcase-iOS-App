//
//  DataService.swift
//  Project-Showcase
//
//  Created by Nick on 2016-02-06.
//  Copyright © 2016 Nicholas Ivanecky. All rights reserved.
//

import Foundation
import Firebase

class DataService {
    
    static let ds = DataService()
    
    private var _REF_BASE = Firebase(url: "https://beam-showcase.firebaseio.com")
    
    var REF_BASE: Firebase {
        return _REF_BASE
    }
}
