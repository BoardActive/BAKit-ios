//
//  ContainerViewController.swift
//  AdDrop
//
//  Created by Ed Salter on 9/9/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    enum SlideOutState {
        case bothCollapsed
        case leftPanelExpanded
    }
    
    var homeViewController: HomeViewController!
    var homeViewConNavigationController: UINavigationController!
    var leftViewController: SidePanelViewController?
    let centerPanelExpandedOffset: CGFloat = 90

    var currentState: SlideOutState = .bothCollapsed {
        didSet {
            let shouldShowShadow = currentState != .bothCollapsed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        homeViewController = UIStoryboard.homeViewController()
        homeViewController.delegate = self
        
        // wrap the centerViewController in a navigation controller, so we can push views to it
        // and display bar button items in the navigation bar
        homeViewConNavigationController = UINavigationController(rootViewController: homeViewController)
        homeViewConNavigationController.navigationBar.isTranslucent = false
        homeViewConNavigationController.navigationBar.barTintColor = #colorLiteral(red: 0.1607843137, green: 0.7137254902, blue: 0.9647058824, alpha: 1)

        view.addSubview(homeViewConNavigationController.view)
        addChildViewController(homeViewConNavigationController)
        
        homeViewConNavigationController.didMove(toParentViewController: self)
        
//        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
//        homeViewConNavigationController.view.addGestureRecognizer(panGestureRecognizer)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

private extension UIStoryboard {
    static func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }
    
    static func leftViewController() -> SidePanelViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "LeftViewController") as? SidePanelViewController
    }
    
    static func homeViewController() -> HomeViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
    }
}

// MARK: CenterViewController delegate

extension ContainerViewController: HomeViewControllerDelegate {
    func toggleMenu() {
        let notAlreadyExpanded = (currentState != .leftPanelExpanded)
        
        if notAlreadyExpanded {
            addLeftPanelViewController()
        } else {
            NotificationCenter.default.post(name: NSNotification.Name("New Local"), object: nil, userInfo: nil)
        }
        
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func addLeftPanelViewController() {
        guard leftViewController == nil else { return }
        
        if let vc = UIStoryboard.leftViewController() {
            vc.delegate = homeViewController
            addChildSidePanelController(vc)
            leftViewController = vc
        }
    }
    
    func animateLeftPanel(shouldExpand: Bool) {
        if shouldExpand {
            currentState = .leftPanelExpanded
            animateCenterPanelXPosition(
                targetPosition: homeViewConNavigationController.view.frame.width - centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { _ in
                self.currentState = .bothCollapsed
                self.leftViewController?.view.removeFromSuperview()
                self.leftViewController = nil
            }
        }
    }
    
    func collapseMenu() {
        switch currentState {
        case .leftPanelExpanded:
            toggleMenu()
        default:
            break
        }
    }
    
    func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut, animations: {
                        self.homeViewConNavigationController.view.frame.origin.x = targetPosition
        }, completion: completion)
    }
    
    func addChildSidePanelController(_ sidePanelController: SidePanelViewController) {
        view.insertSubview(sidePanelController.view, at: 0)
        addChildViewController(sidePanelController)
        sidePanelController.didMove(toParentViewController: self)
    }
    
    func showShadowForCenterViewController(_ shouldShowShadow: Bool) {
        if shouldShowShadow {
            homeViewConNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            homeViewConNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
}


// MARK: Gesture recognizer

//extension ContainerViewController: UIGestureRecognizerDelegate {
//    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
//        let gestureIsDraggingFromLeftToRight = (recognizer.velocity(in: view).x > 0)
//
//        switch recognizer.state {
//        case .began:
//            if currentState == .bothCollapsed {
//                if gestureIsDraggingFromLeftToRight {
//                    addLeftPanelViewController()
//                }
//
//                showShadowForCenterViewController(true)
//            }
//
//        case .changed:
//            if let rview = recognizer.view {
//                rview.center.x = rview.center.x + recognizer.translation(in: view).x
//                recognizer.setTranslation(CGPoint.zero, in: view)
//            }
//
//        case .ended:
//            if let _ = leftViewController,
//                let rview = recognizer.view {
//                // animate the side panel open or closed based on whether the view
//                // has moved more or less than halfway
//                let hasMovedGreaterThanHalfway = rview.center.x > view.bounds.size.width
//                animateLeftPanel(shouldExpand: hasMovedGreaterThanHalfway)
//            }
//
//        default:
//            break
//        }
//    }
//}
