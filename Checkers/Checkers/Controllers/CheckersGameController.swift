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
    
    fileprivate var currentPlayer = Player.red
    
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
    
    //MARK: - Public methods
    init() {
        boardState = setupInitialBoard()
        //loadGameState()
    }
    
    func positionSelected(_ chosenPosition: IndexPath){
        if let currentPosition = currentlySelectedPosition, performMove(start: currentPosition, end: chosenPosition) {
            delegate?.checkersGameControllerUpdatedBoard()
            currentlySelectedPosition = nil
            playerHasMoved = true
            if moveWasJump {
                currentlySelectedPosition = chosenPosition
            }
        }else if boardState[chosenPosition.section][chosenPosition.row]?.owner == currentPlayer && !playerHasMoved {
            currentlySelectedPosition = chosenPosition
            delegate?.pieceSelectedAt(chosenPosition)
        }else if chosenPosition == currentlySelectedPosition{
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
        //saveGameState(boardState: boardState, currentPlayer: currentPlayer)
    }
    
    func resetGame(){
        boardState = setupInitialBoard()
        currentPlayer = .red
        playerHasMoved = false
        moveWasJump = false
        delegate?.checkersGameControllerUpdatedBoard()
        delegate?.activePlayerChanged(toPlayer: .red)
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
        if end.section == start.section + (directionMultiplier) && !playerHasMoved{
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
                //If you want to set moveWasJump to true, always do so after calling movePiece because movePiece will set moveWasJump to false
                movePiece(from: start, to: end)
                moveWasJump = true
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
        moveWasJump = false
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

////MARK: - Persistence
//extension CheckersGameController {
//    private enum JSONKeys : String {
//        case currentPlayer
//        case boardState
//    }
//
//    var dictionaryRepresentation: [String:Any] {
//        var dictionary: [String: Any] = [:]
//        dictionary.updateValue(boardState, forKey: JSONKeys.boardState.rawValue)
//        dictionary.updateValue(currentPlayer, forKey: JSONKeys.currentPlayer.rawValue)
//        return dictionary
//    }
//
//    func restore(from dictionary: Dictionary<String, Any>){
//        guard let boardState = dictionary[JSONKeys.boardState.rawValue] as? [[CheckersPiece?]], let currentPlayer = dictionary[JSONKeys.currentPlayer.rawValue] as? Player else {
//            NSLog("Cannot restore state from dictionary because not all requried values were stored in the provided dictionary")
//            return
//        }
//        self.currentPlayer = currentPlayer
//        self.boardState = boardState
//    }
//
//    func saveGameState(boardState: [[CheckersPiece?]], currentPlayer: Player){
//        do {
//            let data = try JSONSerialization.data(withJSONObject: self.dictionaryRepresentation, options: .prettyPrinted)
//            try data.write(to: fileURL())
//        } catch let error {
//            NSLog("Cannot save game due to error: \(error.localizedDescription)")
//        }
//    }
//
//    func loadGameState(){
//        do {
//            let data = try Data(contentsOf: fileURL())
//            guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] else {
//                NSLog("Could not restore from saved data because there was no saved dictionary")
//                return
//            }
//            restore(from: dictionary)
//        } catch let error {
//            NSLog("Could not load game state due to error: \(error.localizedDescription)")
//        }
//    }
//
//    private func fileURL() -> URL {
//        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        let fileName = "checkers_state.json"
//        let fullURL = urls[0].appendingPathComponent(fileName)
//        return fullURL
//    }
//}

