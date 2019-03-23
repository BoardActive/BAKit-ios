
//
//  ViewController.swift
//  BAKit
//
//  Created by HVNT on 08/23/2018.
//  Copyright (c) 2018 HVNT. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var openBoardActiveButton: UIButton!
    @IBOutlet var infoLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateInfoLabel(object:)), name: NSNotification.Name(.InfoUpdateNotification), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func updateInfoLabel(object: Any?) {
        DispatchQueue.main.async(execute: { () -> Void in
            let str: String = "\(String(describing: object))"
            self.infoLabel.text = str
        })
    }
}
