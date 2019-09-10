//
//  AppPickingViewController.swift
//  AdDrop
//
//  Created by Ed Salter on 7/31/19.
//  Copyright © 2019 BoardActive. All rights reserved.
//

import BAKit
import UIKit
import CoreData

class AppPickingViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        resetApps()
        
        guard let apps = CoreDataStack.sharedInstance.fetchAppsFromDatabase() else {
            let alertController = UIAlertController(title: "No Apps Found", message: "No apps are associated with the current user.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true) {
                self.navigationController?.popToRootViewController(animated: true)
            }
            return
        }

        self.tableView.tableFooterView = UIView()
        
        StorageObject.container.apps = apps

        tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        resetApps()
    }
    
    func resetApps() {
        StorageObject.container.apps = []
    }

    func configureNavigationBar() {
        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "Montserrat-SemiBold", size: 21)!]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StorageObject.container.apps.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.font = UIFont(name: "Montserrat-Regular", size: 17)
        if let text = StorageObject.container.apps[indexPath.row].value(forKey: "name") as? String {
            cell.textLabel?.text = text
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let appKey = BoardActive.client.userDefaults?.string(forKey: String.ConfigKeys.AppKey), let appId = StorageObject.container.apps[indexPath.row].value(forKeyPath: "id") {
            BoardActive.client.setupEnvironment(appID: "\(appId)", appKey: appKey)
            BoardActive.client.userDefaults?.set(true, forKey: "AppSelected")
            BoardActive.client.userDefaults?.set(appId, forKey: "AppIdSelected")
            BoardActive.client.userDefaults?.synchronize()
        }
        
//        if let homeViewController = storyboard?.instantiateViewController(withIdentifier: "HomeViewController") {
//            navigationController?.pushViewController(homeViewController, animated: true)
//        }
        let containerViewController = ContainerViewController()
        navigationController?.pushViewController(containerViewController, animated: true)
    }
}
