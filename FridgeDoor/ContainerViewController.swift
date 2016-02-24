//
//  ContainerViewController.swift
//  FridgeDoor
//
//  Created by K Sabbak on 2/17/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit

enum SlideOutState {
    case Collapsed
    case MenuPanelExpanded
    //case RightPanelExpanded
}



class ContainerViewController: UIViewController, UIGestureRecognizerDelegate, CenterViewControllerDelegate {

    var tapGestureRecognizer: UITapGestureRecognizer!
    var centerNavigationController: UINavigationController!
    var centerViewController: ListViewController!
    var currentState: SlideOutState = .Collapsed  {
        didSet {
            let shouldShowShadow = currentState != .Collapsed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }
    var leftViewController: SettingsViewController?
    let centerPanelExpandedOffset: CGFloat = 150
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centerViewController = UIStoryboard.centerViewController()
        centerViewController.menuDelegate = self
        
        
        // wrap the centerViewController in a navigation controller, so we can push views to it
        // and display bar button items in the navigation bar
        centerNavigationController = UINavigationController(rootViewController: centerViewController)
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        
        centerNavigationController.didMoveToParentViewController(self)
        
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)
        //panGestureRecognizer.delegate = self

        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
        centerNavigationController.view.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.enabled = false

    }
    



// MARK: CenterViewController delegate


    
    func toggleLeftPanel() {
        let notAlreadyExpanded = (currentState != .MenuPanelExpanded)
        
        if notAlreadyExpanded {
            addLeftPanelViewController()
        }
        
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func toggleRightPanel() {
    }
    
    func addLeftPanelViewController() {
        if (leftViewController == nil) {
            leftViewController = UIStoryboard.leftViewController()
            
            addChildSidePanelController(leftViewController!)
        }
    }
    
    
    func addChildSidePanelController(sidePanelController: SettingsViewController) {
        
        sidePanelController.performSeguesForSettingsVCDelegate = centerViewController
        
        view.insertSubview(sidePanelController.view, atIndex: 0)
        
        addChildViewController(sidePanelController)
        sidePanelController.didMoveToParentViewController(self)
    }
    
    func addRightPanelViewController() {
    }
    
    func animateLeftPanel(shouldExpand shouldExpand: Bool) {

        
        if (shouldExpand) {
            currentState = .MenuPanelExpanded
            
            animateCenterPanelXPosition(targetPosition: CGRectGetWidth(centerNavigationController.view.frame) - centerPanelExpandedOffset)

            tapGestureRecognizer.enabled = true

            
        }
        else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.currentState = .Collapsed

                self.leftViewController!.view.removeFromSuperview()
                self.leftViewController = nil
                

            }
            tapGestureRecognizer.enabled = false
        }

    }
    
    func animateCenterPanelXPosition(targetPosition targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.centerNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    
    
//    func animateRightPanel(shouldExpand shouldExpand: Bool) {
//    }
    
    
    func showShadowForCenterViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            centerNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
        }
    }




    // MARK: Gesture recognizer
    
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)
        
        switch(recognizer.state) {
        case .Began:
            if (currentState == .Collapsed) {
                if (gestureIsDraggingFromLeftToRight) {
                    addLeftPanelViewController()
                }
                
                showShadowForCenterViewController(true)
            }
        case .Changed:
            if recognizer.velocityInView(view).x > 0 || currentState == .MenuPanelExpanded
            {
            recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
            recognizer.setTranslation(CGPointZero, inView: view)
            }
        case .Ended:
            if (leftViewController != nil) {
                if currentState == .Collapsed
                {
                    let hasMovedEnough = recognizer.view!.center.x > view.bounds.size.width * 0.6
                    animateLeftPanel(shouldExpand: hasMovedEnough)
                }
                else if currentState == .MenuPanelExpanded{
                // animate the side panel open or closed based on whether the view has moved more or less than halfway
                let hasMovedEnough = recognizer.view!.center.x > view.bounds.size.width * 2
                animateLeftPanel(shouldExpand: hasMovedEnough)
                }
            }
//            else if (rightViewController != nil) {
//                let hasMovedGreaterThanHalfway = recognizer.view!.center.x < 0
//                animateRightPanel(shouldExpand: hasMovedGreaterThanHalfway)
//            }
        default:
            break
        }
    }
    
    
    func handleTapGesture(recognizer: UITapGestureRecognizer)
    {
        
        if currentState == .MenuPanelExpanded
        {
        animateLeftPanel(shouldExpand: false)
       // recognizer.enabled = false
            
        }
        if currentState == .Collapsed
        {
           // recognizer.enabled = false
            print(":(")
            print(recognizer.enabled.boolValue)
        }
    }
}

private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func leftViewController() -> SettingsViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("SettingsViewController") as? SettingsViewController
    }
    
  
    
    class func centerViewController() -> ListViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("ListViewController") as? ListViewController
    }
    
}
