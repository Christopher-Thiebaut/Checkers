//
//  CheckersGameController.swift
//  Checkers
//
//  Created by Christopher Thiebaut on 2/22/18.
//  Copyright © 2018 Christopher Thiebaut. All rights reserved.
//

import Foundation

protocol CheckersGameControllerDelegate: class {
    
    func checkersGameControllerUpdatedBoard()
    
    func playerWonGame(winner: Player)
    
    ///The delegate should use this function to update UI based on what peice is currently selected.
    func pieceSelectedAt(_ position: IndexPath)
}

class CheckersGameController {
    
    var currentPlayer = Player.red
    
    var boardState: [[CheckersPiece?]] = []
    
    private var currentlySelectedPosition: IndexPath?
    
    weak var delegate: CheckersGameControllerDelegate?
    
    let boardSize = 8
    
    private var justDidType1Row = false
    
    init() {
        setupInitialBoard()
    }
    
//    func positionSelected(indexPath: IndexPath){
//        if let currentPosition = currentlySelectedPosition {
//
//        }
//    }
//
    
    private func isLegalMove(start: IndexPath, end: IndexPath) -> Bool {
        guard let piece = boardState[start.section][start.row], piece.owner == currentPlayer  else {
            return false
        }
        let directionMultiplier = currentPlayer == Player.red ? 1 : -1
        if end.section == start.section + (directionMultiplier){
            if boardState[end.section][end.row] != nil {
                return false
            }
            if end.row == start.row + 1 || end.row == start.row - 1 {
                return true
            }else{
                return false
            }
        }else if end.section == start.section + (directionMultiplier * 2){
            if boardState[end.section][end.row] != nil {
                return false
            }
            let jumpedSpace = boardState[end.section - 1][(start.row + end.row)/2]
            if let jumpedOwner = jumpedSpace?.owner, jumpedOwner != currentPlayer {
                return true
            }else{
                return false
            }
        }else{
            return false
        }
    }
    
    private func setupInitialBoard(){
        var board: [[CheckersPiece?]] = []
        let playerSpace = (boardSize/2) - 2
        
        for _ in 0..<playerSpace {
            if justDidType1Row {
                board.append(createRowPrototype2(forPlayer: Player.black))
            }else{
                board.append(createRowPrototype1(forPlayer: Player.black))
            }
        }
        board.append(createEmptyRow())
        board.append(createEmptyRow())
        for _ in 0..<playerSpace {
            if justDidType1Row {
                board.append(createRowPrototype2(forPlayer: Player.red))
            }else{
                board.append(createRowPrototype1(forPlayer: Player.red))
            }
        }
    }
    
    private func createRowPrototype1(forPlayer player: Player) -> [CheckersPiece?]{
        var row: [CheckersPiece?] = []
        for position in 0..<boardSize {
            if position % 2 == 0 {
                row.append(nil)
            }else{
                row.append(CheckersPiece(owner: player))
            }
        }
        justDidType1Row = true
        return row
    }
    
    private func createRowPrototype2(forPlayer player: Player) -> [CheckersPiece?]{
        var row: [CheckersPiece?] = []
        for position in 0..<boardSize {
            if position % 2 != 0 {
                row.append(nil)
            }else{
                row.append(CheckersPiece(owner: player))
            }
        }
        justDidType1Row = false
        return row
    }
    
    private func createEmptyRow() -> [CheckersPiece?]{
        var row: [CheckersPiece?] = []
        for _ in 0..<boardSize {
            row.append(nil)
        }
        justDidType1Row = !justDidType1Row
        return row
    }
    
}
