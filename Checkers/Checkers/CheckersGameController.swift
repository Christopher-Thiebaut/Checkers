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
    
    func checkersGameControllerSelectedPosition(_ position: IndexPath)
}

class CheckersGameController {
    
    var currentPlayer = Player.player1
    
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
//    private func isLegalMove(start: IndexPath, end: IndexPath) -> Bool {
//        guard let piece = boardState[start.section][start.row], piece.owner == currentPlayer  else {
//            return false
//        }
//        var directionMultiplier = currentPlayer == Player.player1 ? 1 : -1
//        if end.section == start.section + (directionMultiplier){
//
//        }
//    }
    
    private func setupInitialBoard(){
        var board: [[CheckersPiece?]] = []
        let playerSpace = (boardSize/2) - 2
        
        for _ in 0..<playerSpace {
            if justDidType1Row {
                board.append(createRowPrototype2(forPlayer: Player.player2))
            }else{
                board.append(createRowPrototype1(forPlayer: Player.player2))
            }
        }
        board.append(createEmptyRow())
        board.append(createEmptyRow())
        for _ in 0..<playerSpace {
            if justDidType1Row {
                board.append(createRowPrototype2(forPlayer: Player.player1))
            }else{
                board.append(createRowPrototype1(forPlayer: Player.player1))
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
