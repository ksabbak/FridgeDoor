//
//  AvatarViewController.swift
//  FridgeDoor
//
//  Created by K Sabbak on 2/19/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit

class AvatarViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var avatarArray = [String]()
    var avatarImageName: String!
    var indexPathRow = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
  
        for i in 1 ... 5
        {
            avatarArray.append("\(i)")
        }
        
    }


    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AvatarCell", forIndexPath: indexPath) as! AvatarCollectionViewCell
        
        cell.avatarImageView.image = UIImage(imageLiteral: avatarArray[indexPath.item])
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return avatarArray.count
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        indexPathRow = avatarArray[indexPath.item]
        print("----> \(self) :: \(indexPathRow)")
//        performSegueWithIdentifier("avatarsegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if indexPathRow.isEmpty == false
        {
            avatarImageName = indexPathRow
        }
        
        //= "THIS IS A TEST"
        print("- - - - > \(avatarImageName)")
    }
    
}
