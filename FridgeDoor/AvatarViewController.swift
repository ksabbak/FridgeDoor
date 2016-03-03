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
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
  
        for i in 1 ... 20
        {
            avatarArray.append("\(i)")
        }
        
        view.backgroundColor = UIColor.appDarkBlueColor()
    }

    override func viewWillAppear(animated: Bool)
    {
//        collectionView.backgroundColor = UIColor.appVeryLightBlueColor()
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
//        cell.backgroundColor = UIColor.appVeryLightBlueColor()
        
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
    
    @IBAction func dismissButtonTapped(sender: UIButton)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
