//
//  MainViewController.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 23. 10. 2024..
//

import UIKit

class MainViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupUI()
//        fetchShows()
//        log.info("\n")
        fetchShow(byId: 20)
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
    
    private func setupUI() {
        tabBar.backgroundColor = .screenColor
        tabBar.tintColor = .brightYellow
        tabBar.unselectedItemTintColor = .textColor
        
        if let scrollView = view.subviews.compactMap({ $0 as? UIScrollView }).first {
            let canScroll = scrollView.contentSize.height > scrollView.frame.size.height
            if canScroll {
                enableBlurEffect()
            }
        }
        log.info("Main View did Load")
    }
    
    private func enableBlurEffect() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = tabBar.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        tabBar.backgroundColor = .clear
        tabBar.addSubview(blurEffectView)
        tabBar.sendSubviewToBack(blurEffectView)
    }
    
    // MARK: - Navigation
    
    // MARK: - Test
    func fetchShow(byId id: Int) {
        TVMazeClient.shared.fetchShow(byId: id) { response in
            switch response {
            case .success(let show):
                log.info(show)
            case .failure(let errorMessage):
                log.error(errorMessage)
            }
        }
    }
    
    func fetchShows() {
        
        TVMazeClient.shared.fetchShows() { response in
            switch response {
            case .success(let shows):
                for show in shows {
                    log.info(show)
                }
            case .failure(let error):
                log.error(error)
            }
        }
        
//        let url = URL(string: "https://api.tvmaze.com/shows")!
//        
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//            guard let data = data, error == nil else { return }
//            
//            do {
//                let shows = try JSONDecoder().decode([Show].self, from: data)
//                let dbManager = Database()
//                for show in shows {
//                    dbManager.insertShow(show)
//                }
//            } catch {
//                print("Failed to decode JSON: \(error)")
//            }
//        }
//        
//        task.resume()
    }
    
//    func printShows() {
//        do {
//            let shows = try Database.dbQueue.read { db in
//                try Show.fetchAll(db)
//            }
//            
//            if shows.isEmpty {
//                log.error("No shows found in the database")
//                return
//            }
//            
//            let seasons = try Database.dbQueue.read { db in
//                try Season.fetchAll(db)
//            }
//            
//            for show in shows {
//                log.info(show)
//            }
//            
//        } catch {
//            log.error("Error fetching: \(error)")
//        }
//    }
}
