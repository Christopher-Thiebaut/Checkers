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
    
    func activePlayerChanged(toPlayer player: Player)
    
    ///The delegate should use this function to update UI based on what peice is currently selected.
    func pieceSelectedAt(_ position: IndexPath)
}
///A controller to maintain the state of a checkers game.  The controller notifies its delegate of significant changes to the game state, such as pieces moving or being destroyed.
///You can send messages to the CheckersGameController through 3 functions: positionSelected, switchPlayers, and resetGame. positionSelected should be used to inform the controller that a player interacted with a part of the game board.  The controller will decide of the interaction constitutes a legal move and notify its delegate accordingly.  switchPlayers should be used to notify the controller that the active player has switched and the controller should now only allow interaction with the pieces of the appropriate player.  resetGame restores the game to its initial state.
class CheckersGameController {
    
    var currentPlayer = Player.red
    
    var boardState: [[CheckersPiece?]] = []
    
    var playerHasMoved = false
    var moveWasJump = false
    
    private var currentlySelectedPosition: IndexPath?
    
    var blackPieces = 0 {
        didSet {
            if blackPieces == 0 {
                delegate?.playerWonGame(winner: .red)
            }else if blackPieces < 0 {
                fatalError("Fix your piece counting logic, dummy")
            }
        }
    }
    var redPieces = 0{
        didSet {
            if redPieces == 0 {
                delegate?.playerWonGame(winner: .black)
            }else if redPieces < 0 {
                fatalError("Fix your piece counting logic, dummy")
            }
        }
    }
    
    weak var delegate: CheckersGameControllerDelegate?
    
    let boardSize = 8
    
    private var lastRowStartedWithEmptySpace = false
    
    init() {
        boardState = setupInitialBoard()
    }
    
    func positionSelected(_ chosenPosition: IndexPath){
        if let currentPosition = currentlySelectedPosition, performMove(start: currentPosition, end: chosenPosition) {
            delegate?.checkersGameControllerUpdatedBoard()
            currentPlayer = currentPlayer == .red ? .black : .red
            currentlySelectedPosition = nil
            playerHasMoved = true
        }else if boardState[chosenPosition.section][chosenPosition.row]?.owner == currentPlayer {
            currentlySelectedPosition = chosenPosition
            delegate?.pieceSelectedAt(chosenPosition)
        }
    }
    
    func switchPlayers(){
        guard playerHasMoved else {
            return
        }
        switch currentPlayer {
        case .red:
            currentPlayer = .black
        case .black:
            currentPlayer = .red
        }
        playerHasMoved = false
        moveWasJump = false
        delegate?.activePlayerChanged(toPlayer: currentPlayer)
    }
    
    func resetGame(){
        boardState = setupInitialBoard()
        delegate?.checkersGameControllerUpdatedBoard()
    }

    //MARK: - Movement
    private func performMove(start: IndexPath, end: IndexPath) -> Bool {
        guard let piece = boardState[start.section][start.row], piece.owner == currentPlayer  else {
            return false
        }
        if piece.isKing {
            if performMove(start: start, end: end, towardTop: true) {
                return true
            }else{
                return performMove(start: start, end: end, towardTop: false)
            }
        }else if currentPlayer == .red {
            return performMove(start: start, end: end, towardTop: true)
        }else{
            return performMove(start: start, end: end, towardTop: false)
        }
    }
    
    private func performMove(start: IndexPath, end: IndexPath, towardTop: Bool) -> Bool {
        guard let piece = boardState[start.section][start.row], piece.owner == currentPlayer  else {
            return false
        }
        let directionMultiplier = towardTop ? -1 : 1
        if end.section == start.section + (directionMultiplier){
            if boardState[end.section][end.row] != nil {
                return false
            }
            if end.row == start.row + 1 || end.row == start.row - 1 {
                movePiece(from: start, to: end)
                return true
            }else{
                return false
            }
        }else if end.section == start.section + (directionMultiplier * 2){
            if boardState[end.section][end.row] != nil {
                return false
            }
            let jumpedIndexPath = IndexPath.init(row: (start.row + end.row)/2, section: end.section - directionMultiplier)
            let jumpedPiece = boardState[jumpedIndexPath.section][jumpedIndexPath.row]
            if let jumpedOwner = jumpedPiece?.owner, jumpedOwner != currentPlayer {
                //Remove the jumped piece
                boardState[jumpedIndexPath.section][jumpedIndexPath.row] = nil
                updatePiecesCount(forPlayer: jumpedOwner, adjustBy: -1)
                moveWasJump = true
                movePiece(from: start, to: end)
                return true
            }else{
                return false
            }
        }else{
            return false
        }
    }
    
    private func movePiece(from: IndexPath, to: IndexPath){
        boardState[to.section][to.row] = boardState[from.section][from.row]
        boardState[from.section][from.row] = nil
        if let piece = boardState[to.section][to.row], shouldBeKing(piece, position: to) {
            piece.isKing = true
        }
    }
    
    private func shouldBeKing(_ piece: CheckersPiece, position: IndexPath) -> Bool {
        if piece.isKing { return true }
        switch piece.owner {
        case .red:
            return position.section == 0
        case .black:
            return (position.section == boardSize - 1)
        }
    }
    
    //MARK: - Setup
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
    
    private func updatePiecesCount(forPlayer player: Player, adjustBy numPieces: Int){
        switch player {
        case .black:
            blackPieces += numPieces
        case .red:
            redPieces += numPieces
        }
    }
    
    private func createRowWithEmptyStart(forPlayer player: Player) -> [CheckersPiece?]{
        var row: [CheckersPiece?] = []
        for position in 0..<boardSize {
            if position % 2 == 0 {
                row.append(nil)
            }else{
                row.append(CheckersPiece(owner: player))
                updatePiecesCount(forPlayer: player, adjustBy: 1)
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
                updatePiecesCount(forPlayer: player, adjustBy: 1)
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
