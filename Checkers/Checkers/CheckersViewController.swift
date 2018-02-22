//
//  CheckersViewController.swift
//  Checkers
//
//  Created by Isidore Baldado on 2/22/18.
//  Copyright © 2018 Christopher Thiebaut. All rights reserved.
//

import UIKit

class CheckersViewController: UIViewController {
    
    // Mock Model Controller
    var gameState: [[Int]] =
    [[1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [0,0,0,0,0,0,0,0],
     [0,0,0,0,0,0,0,0],
     [2,2,2,2,2,2,2,2],
     [2,2,2,2,2,2,2,2]]
    var gameController = CheckersGameController()
    var lastSelectedIndex: IndexPath?
    
    // Black Magic for setting up size
    fileprivate let sectionInsets = UIEdgeInsets(top: 2.5, left: 0.0, bottom: 2.5, right: 0.0)
    fileprivate let itemsPerRow: CGFloat = 9

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("DEBUG: Row Count: \(gameController.boardState.count)")
        print("DEBUG: Column Count: \(gameController.boardState[0].count)")
        for row in gameController.boardState{
            print (row.map({ (piece) -> Int in
                if piece == nil {return 0}
                if piece!.owner == .red {return 1}
                else {return 2}
            }))
        }
        
        gameController.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CheckersViewController: CheckersGameControllerDelegate{
    func checkersGameControllerUpdatedBoard() {
        collectionView.reloadData()
    }
    
    func playerWonGame(winner: Player) {
        
    }
    
    func pieceSelectedAt(_ position: IndexPath) {
        guard let lastIndex = lastSelectedIndex else {
            highlightCell(at: position)
            return
        }
        
        if lastIndex != position{
            dehighlightCell(at: lastIndex)
            lastSelectedIndex = position
            highlightCell(at: position)
        }
    }
    
    // HELPER
    
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
        
        cell.backgroundColor = UIColor.blue
        let piece = gameController.boardState[indexPath.section][indexPath.row]
        
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

        if piece == nil{
            //nothing!
            cell.imageView!.image = nil
            return cell
        }
        cell.imageView?.image = UIImage(named: piece!.owner == .red ? "red" : "black")
        
        
//        let colors = [UIColor.green, UIColor.blue, UIColor.red]
//        let debugState = gameState[indexPath.section][indexPath.row]
//        cell.backgroundColor = colors[debugState]
//        cell.imageView?.image = UIImage(named: ["null","red","black"][debugState])
        
        return cell
    }
    
}

extension CheckersViewController: UICollectionViewDelegate {
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected: Sect:\(indexPath.section) Row:\(indexPath.row)")
        gameController.positionSelected(indexPath)
//        let emptyRow = Array<CheckersPiece?>.init(repeating: nil, count: 8)
//        for i in 0...7{
//            gameController.boardState[i] = emptyRow
//        }
    }
}

extension CheckersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow

        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
