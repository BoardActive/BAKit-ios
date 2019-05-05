//
//  OnboardingPageViewController.swift
//  BAKit
//
//  Created by Ed Salter on 4/19/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import UIKit

class OnboardingPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adjustAppearance()
        
        createViewControllers()
    }
    
    func adjustAppearance() {
        let appearance = UIPageControl.appearance(whenContainedInInstancesOf: [OnboardingPageViewController.self, OnboardingViewController.self])
        appearance.pageIndicatorTintColor = UIColor.gray
        appearance.currentPageIndicatorTintColor = UIColor.blue
    }
    
    func createViewControllers() {
        for i in 0...4 {
            switch i {
            case 0:
                let viewController = OnboardingViewController()
                viewController.imageView.image = UIImage(named: "step-1")
                viewController.headlineLabel.text = String.Step1HeadlineText
                viewController.bodyLabel.text = String.Step1BodyText
                viewController.previousButton.isHidden = true
                break
            case 1:
                let viewController = OnboardingViewController()
                viewController.imageView.image = UIImage(named: "step-2")
                viewController.headlineLabel.text = String.Step2HeadlineText
                viewController.bodyLabel.text = String.Step2BodyText
                viewController.previousButton.isHidden = false
                viewController.nextButton.isHidden = false
                break
            case 2:
                let viewController = OnboardingViewController()
                viewController.imageView.image = UIImage(named: "step-3")
                viewController.headlineLabel.text = String.Step3HeadlineText
                viewController.bodyLabel.text = String.Step3BodyText
                viewController.previousButton.isHidden = false
                viewController.nextButton.isHidden = false
                break
            case 3:
                let viewController = OnboardingViewController()
                viewController.imageView.image = UIImage(named: "step-4")
                viewController.headlineLabel.text = String.Step4HeadlineText
                viewController.bodyLabel.text = String.Step4BodyText
                viewController.previousButton.isHidden = false
                viewController.nextButton.isHidden = false
                break
            case 4:
                let viewController = OnboardingViewController()
                viewController.imageView.image = UIImage(named: "step-1")
                viewController.headlineLabel.text = String.Step1HeadlineText
                viewController.bodyLabel.text = String.Step1BodyText
                viewController.previousButton.isHidden = false
                viewController.nextButton.isHidden = true
                break
            default:
                break
            }
        }
    }
    
    // MARK: UIPageViewControllerDataSource Functions
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return viewControllers?[(viewControllers?.index(of: viewController))!]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return viewControllers?[(viewControllers?.index(of: viewController))!]
    }
}
