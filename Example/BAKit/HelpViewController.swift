//
//  InfoViewController.swift
//  BAKit_Example
//
//  Created by Ed Salter on 7/25/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import UIKit
import BAKit

class HelpViewController: UIViewController {

    @IBOutlet weak var signOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signOutAction(_ sender: Any) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        queue.addOperation {
            self.tabBarController?.selectedIndex = 0
        }
        
        queue.addOperation {
            BoardActive.client.signOut()
        }
        
        
//        let switchIndexOperation = BlockOperation {
//            self.tabBarController?.selectedIndex = 0
//        }
//        
//        let signOutOperation = BlockOperation {
//            BoardActive.client.signOut()
//        }
//        
//        signOutOperation.addDependency(switchIndexOperation)
//        
//        queue.addOperation {
//            <#code#>
//        }
        
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
