//
//  SidePanelViewController.swift
//  AdDrop
//
//  Created by Ed Salter on 9/9/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import UIKit

class SidePanelViewController: UITableViewController {
    
    var delegate: SidePanelViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.reloadData()
    }

// MARK: Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else {
            return 5
        }
    }

// Mark: Table View Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                delegate?.didSelectCellWithTitle("View Token")
                return
            case 1:
                delegate?.didSelectCellWithTitle("Device")
                return
            case 2:
                delegate?.didSelectCellWithTitle("App Variables")
                return
            default:
                break
            }
        }
        
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                UserDefaults.extensions.set("Basic", forKey: "categoryIdentifier")
                UserDefaults.extensions.synchronize()
                break
            case 1:
                UserDefaults.extensions.set("Big Picture", forKey: "categoryIdentifier")
                UserDefaults.extensions.synchronize()
                break
            case 2:
                UserDefaults.extensions.set("Action Button", forKey: "categoryIdentifier")
                UserDefaults.extensions.synchronize()
                break
            case 3:
                UserDefaults.extensions.set("Big Text", forKey: "categoryIdentifier")
                UserDefaults.extensions.synchronize()
                break
            case 4:
                UserDefaults.extensions.set("Inbox Style", forKey: "categoryIdentifier")
                UserDefaults.extensions.synchronize()
                break
            default:
                break
            }
        }
        delegate?.didSelectCellWithTitle(UserDefaults.extensions.string(forKey: "categoryIdentifier")!)
    }
}

protocol SidePanelViewControllerDelegate {
    func didSelectCellWithTitle(_ title:String)
}
