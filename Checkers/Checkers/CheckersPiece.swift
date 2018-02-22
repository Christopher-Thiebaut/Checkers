//
//  CheckersPiece.swift
//  Checkers
//
//  Created by Christopher Thiebaut on 2/22/18.
//  Copyright © 2018 Christopher Thiebaut. All rights reserved.
//

import Foundation

struct CheckersPiece {
    let owner: Player
    var isKing = false
    
    init(owner: Player){
        self.owner = owner
    }
}

enum Player {
    case red
    case black
}
