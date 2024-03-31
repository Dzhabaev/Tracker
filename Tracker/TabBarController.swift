//
//  TabBarController.swift
//  Tracker
//
//  Created by Chingiz on 29.11.2023.
//

import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .trWhite
        
        // MARK: - Separator
        
        let separator = UIView(frame: CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 1))
        separator.backgroundColor = .trGray
        tabBar.addSubview(separator)
        
        // MARK: - Trackers View Controller
        
        let trackersViewController = TrackersViewController()
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        trackersNavigationController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("trackersVC.UITabBarItem.title", comment: ""),
            image: UIImage(systemName: "record.circle.fill"),
            selectedImage: nil)
        
        // MARK: - Statistics View Controller
        
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("statisticsVC.UITabBarItem.title", comment: ""),
            image: UIImage(systemName: "hare.fill"),
            selectedImage: nil)
        
        self.viewControllers = [trackersNavigationController, statisticsViewController]
    }
}
