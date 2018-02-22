//
//  CheckersViewController.swift
//  Checkers
//
//  Created by Isidore Baldado on 2/22/18.
//  Copyright © 2018 Christopher Thiebaut. All rights reserved.
//

import UIKit

class CheckersViewController: UIViewController {
    
    var gameController = CheckersGameController()
    var lastSelectedIndex: IndexPath?
    
    // Collection View Padding and Sizing
    fileprivate let sectionInsets = UIEdgeInsets(top: 1.5, left: 0.0, bottom: 1.5, right: 0.0)
    fileprivate let itemsPerRow: CGFloat = 9
        // only works wih 9 for now, even though 8 is expected

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameController.delegate = self
        
        print("DEBUG: Row Count: \(gameController.boardState.count)")
        print("DEBUG: Column Count: \(gameController.boardState[0].count)")
        for row in gameController.boardState{
            print (row.map({ (piece) -> Int in
                if piece == nil {return 0}
                if piece!.owner == .red {return 1}
                else {return 2}
            }))
        }
    }

    @IBAction func endTurnButtonPressed(){
        gameController.switchPlayers()
    }

    @IBAction func resentButtonPressed(_ sender: Any) {
        gameController.resetGame()
        lastSelectedIndex = nil
    }
    
}

extension CheckersViewController: CheckersGameControllerDelegate{
    
    func activePlayerChanged(toPlayer player: Player) {
        collectionView.indexPathsForVisibleItems.forEach { (indexPath) in
            dehighlightCell(at: indexPath)
        }
        gameController.switchPlayers()
    }
    
    func checkersGameControllerUpdatedBoard() {
        collectionView.indexPathsForVisibleItems.forEach { (indexPath) in
            dehighlightCell(at: indexPath)
        }
        collectionView.reloadData()
    }
    
    func playerWonGame(winner: Player) {
        
        let winnerAlertController = UIAlertController(title: "Winner!", message: "Congratulations! \(winner == .red ? "Red":"Black") has won!", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Play again", style: .default) { [weak self] _ in
            self?.gameController.resetGame()
            self?.lastSelectedIndex = nil
        }
        winnerAlertController.addAction(okayAction)
        present(winnerAlertController, animated: true)
    }
    
    func pieceSelectedAt(_ position: IndexPath) {
        guard let lastIndex = lastSelectedIndex else {
            highlightCell(at: position)
            lastSelectedIndex = position
            return
        }
        
        if lastIndex != position{
            dehighlightCell(at: lastIndex)
            lastSelectedIndex = position
            highlightCell(at: position)
        }
    }
    
    // Helper Functions to (de)highlight cells
    
    fileprivate func highlightCell(at indexPath: IndexPath){
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell else {
            print("Cell called at \(indexPath), but no cell found")
            return}
        
        cell.imageView?.layer.borderWidth = 5.0
        cell.imageView?.layer.borderColor = UIColor.yellow.cgColor
    }
    
    fileprivate func dehighlightCell(at indexPath: IndexPath){
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell else {
            print("Cell called at \(indexPath), but no cell found")
            return}
        
        cell.imageView?.layer.borderWidth = 5.0
        cell.imageView?.layer.borderColor = UIColor.clear.cgColor}
}


extension CheckersViewController: UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "checkersCell", for: indexPath) as! ImageCollectionViewCell
        
        let piece = gameController.boardState[indexPath.section][indexPath.row]
        
        // Color the board
        if indexPath.section % 2 == 0{
            if indexPath.row % 2 == 0{
                cell.backgroundColor = UIColor.darkGray
            }else{
                cell.backgroundColor = UIColor.white
            }
        }else{
            if indexPath.row % 2 == 0{
                cell.backgroundColor = UIColor.white
            }else{
                cell.backgroundColor = UIColor.darkGray
            }
        }

        // Set piece images
        if piece == nil{
            cell.imageView!.image = nil
            return cell
        }
        
        switch (piece!.isKing, piece!.owner){
        case (true, .red):
            cell.imageView?.image = #imageLiteral(resourceName: "red_king")
        case (false, .red):
            cell.imageView?.image = #imageLiteral(resourceName: "red")
        case (true, .black):
            cell.imageView?.image = #imageLiteral(resourceName: "black_king")
        case (false, .black):
            cell.imageView?.image = #imageLiteral(resourceName: "black")
        }
        
        return cell
    }
    
}

extension CheckersViewController: UICollectionViewDelegate {
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected: Sect:\(indexPath.section) Row:\(indexPath.row)")
        gameController.positionSelected(indexPath)
    }
}

extension CheckersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow

        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
}
