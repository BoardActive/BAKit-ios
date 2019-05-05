//
//  OnboardingViewController.swift
//  BAKit
//
//  Created by Ed Salter on 4/21/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import UIKit

public class OnboardingViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func incrementViewControllers(_ sender: Any) {
        let parentViewController = self.parent as! OnboardingPageViewController
        parentViewController.setViewControllers(parentViewController.viewControllers, direction: .forward, animated: true, completion: nil)
    }
    
    @IBAction func decrementViewControllers(_ sender: Any) {
        let parentViewController = self.parent as! OnboardingPageViewController
        parentViewController.setViewControllers(parentViewController.viewControllers, direction: .reverse, animated: true, completion: nil)
    }
}
