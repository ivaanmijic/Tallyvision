//
//  MainViewController.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 23. 10. 2024..
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupTabBar()
//        configureRoundedTabBar()
    }
    
    private func setupViewControllers() {
        let homeViewController = createNavigationController(HomeViewController(), withImage: "home")
        let discoverViewController = createNavigationController(DiscoverViewController(), withImage: "magnifer")
        let watchlistViewController = createNavigationController(WatchlistViewController(), withImage: "bookmark")
        let statisticsViewController = createNavigationController(StatisticsViewController(), withImage: "chart")
        
        viewControllers = [homeViewController, discoverViewController, watchlistViewController, statisticsViewController]
    }
    
    private func createNavigationController(_ controller: UIViewController, withImage imageName: String) -> UINavigationController {
        let image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate).resizeTo(maxWidth: 30, maxHeight: 30)
        let selectedImage = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate).resizeTo(maxWidth: 30, maxHeight: 30)
       
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.tabBarItem = UITabBarItem(title: nil, image: image, selectedImage: selectedImage)
        navigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        return navigationController
    }
    
    private func setupTabBar() {
        tabBar.tintColor = .baseYellow
        tabBar.unselectedItemTintColor = .textColor
//        tabBar.backgroundImage = UIImage()
//        tabBar.shadowImage = UIImage()
//        tabBar.backgroundColor = .clear
        tabBar.backgroundColor = .appColor
    }
    
}
