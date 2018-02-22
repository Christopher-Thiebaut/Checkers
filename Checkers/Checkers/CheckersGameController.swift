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
    
    private var lastRowStartedWithEmptySpace = false
    
    init() {
        boardState = setupInitialBoard()
    }
    
    func positionSelected(_ chosenPosition: IndexPath){
        if let currentPosition = currentlySelectedPosition, performMove(start: currentPosition, end: chosenPosition) {
            delegate?.checkersGameControllerUpdatedBoard()
        }else if boardState[chosenPosition.section][chosenPosition.row]?.owner == currentPlayer {
            currentlySelectedPosition = chosenPosition
            delegate?.pieceSelectedAt(chosenPosition)
        }
    }

    
    private func performMove(start: IndexPath, end: IndexPath) -> Bool {
        guard let piece = boardState[start.section][start.row], piece.owner == currentPlayer  else {
            return false
        }
        let directionMultiplier = currentPlayer == Player.red ? 1 : -1
        if end.section == start.section + (directionMultiplier){
            if boardState[end.section][end.row] != nil {
                return false
            }
            if end.row == start.row + 1 || end.row == start.row - 1 {
                boardState[end.section][end.row] = piece
                return true
            }else{
                return false
            }
        }else if end.section == start.section + (directionMultiplier * 2){
            if boardState[end.section][end.row] != nil {
                return false
            }
            var jumpedPiece = boardState[end.section - 1][(start.row + end.row)/2]
            if let jumpedOwner = jumpedPiece?.owner, jumpedOwner != currentPlayer {
                jumpedPiece = nil
                
                return true
            }else{
                return false
            }
        }else{
            return false
        }
    }
    
    private func setupInitialBoard() -> [[CheckersPiece?]]{
        var board: [[CheckersPiece?]] = []
        let playerSpace = (boardSize/2) - 1
        
        for _ in 0..<playerSpace {
            if lastRowStartedWithEmptySpace {
                board.append(createRowWithFilledStart(forPlayer: Player.black))
            }else{
                board.append(createRowWithEmptyStart(forPlayer: Player.black))
            }
        }
        board.append(createEmptyRow())
        board.append(createEmptyRow())
        for _ in 0..<playerSpace {
            if lastRowStartedWithEmptySpace {
                board.append(createRowWithFilledStart(forPlayer: Player.red))
            }else{
                board.append(createRowWithEmptyStart(forPlayer: Player.red))
            }
        }
        return board
    }
    
    private func createRowWithEmptyStart(forPlayer player: Player) -> [CheckersPiece?]{
        var row: [CheckersPiece?] = []
        for position in 0..<boardSize {
            if position % 2 == 0 {
                row.append(nil)
            }else{
                row.append(CheckersPiece(owner: player))
            }
        }
        lastRowStartedWithEmptySpace = true
        return row
    }
    
    private func createRowWithFilledStart(forPlayer player: Player) -> [CheckersPiece?]{
        var row: [CheckersPiece?] = []
        for position in 0..<boardSize {
            if position % 2 != 0 {
                row.append(nil)
            }else{
                row.append(CheckersPiece(owner: player))
            }
        }
        lastRowStartedWithEmptySpace = false
        return row
    }
    
    private func createEmptyRow() -> [CheckersPiece?]{
        var row: [CheckersPiece?] = []
        for _ in 0..<boardSize {
            row.append(nil)
        }
        lastRowStartedWithEmptySpace = !lastRowStartedWithEmptySpace
        return row
    }
    
}
