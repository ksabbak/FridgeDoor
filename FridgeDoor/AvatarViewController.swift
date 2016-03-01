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
    var editAvatar = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
  
        for i in 1 ... 5
        {
            avatarArray.append("\(i)")
        }
        
    }


    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenRect: CGRect = UIScreen.mainScreen().bounds
        let screenWidth: CGFloat = screenRect.size.width
        let cellWidth: CGFloat = screenWidth / 3.2
        let size: CGSize = CGSizeMake(cellWidth, cellWidth)
        return size
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AvatarCell", forIndexPath: indexPath) as! AvatarCollectionViewCell
        
        cell.avatarImageView.image = UIImage(imageLiteral: avatarArray[indexPath.item])
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        
        return avatarArray.count
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        indexPathRow = avatarArray[indexPath.item]
        print("----> \(self) :: \(indexPathRow)")
        print("Edit Avatar status: \(editAvatar)")
        if editAvatar
        {
            print("should start unwind to profile segue")
            editAvatar = false
            performSegueWithIdentifier("UnwindToProfile", sender: indexPathRow)
        }
        else
        {
//            self.dismissViewControllerAnimated(true, completion: nil)
            performSegueWithIdentifier("AvatarUnwindSegue", sender: indexPathRow)
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "AvatarUnwindSegue"
        {
            let dvc = segue.destinationViewController as! CreateAccountViewController
            let avatarImageName = sender as! String
            dvc.avatarImageName = avatarImageName
        }
        if segue.identifier == "UnwindToProfile"
        {
            let dvc = segue.destinationViewController as! ProfileViewController
            let avatarImageName = sender as! String
            dvc.avatarImageName = avatarImageName
        }
    }
}
