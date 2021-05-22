//
//  MainTabBarController.swift
//  FileManager
//
//  Created by Dmitrii KRY on 21.05.2021.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController {
    
    let firstController = FileManagerViewController()
    let secondController = SettingsViewController()
    
    func configureFirstTab() -> UINavigationController {
        
        
        let firstNavControleler = UINavigationController(rootViewController: firstController)
        let imageTab = UIImage(systemName: "folder")
        let firstControllerTabBarItem = UITabBarItem(title: "Catalog", image: imageTab, tag: 0)
        firstNavControleler.tabBarItem = firstControllerTabBarItem
        return firstNavControleler
    }
    
    func configureSecondTab() -> UINavigationController {
        
        secondController.delegate = firstController
        let secondNavControleler = UINavigationController(rootViewController: secondController)
        let imageTab = UIImage(systemName: "gearshape")
        let secondControllerTabBarItem = UITabBarItem(title: "Settings", image: imageTab, tag: 1)
        secondNavControleler.tabBarItem = secondControllerTabBarItem
        return secondNavControleler
    }
    
    override func viewDidLoad() {
        viewControllers = [configureFirstTab(), configureSecondTab()]
    }
    
}
