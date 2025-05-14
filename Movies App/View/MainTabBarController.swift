//
//  HomeView.swift
//  Movies App (Inshorts)
//
//  Created by Banavath UdayKiran Naik on 10/05/25.
//

import UIKit

class MainTabBarController: UITabBarController {
    private let viewModel: MoviesViewModelProtocol
    
    init(viewModel: MoviesViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupTabBar()
    }
    
    private func setupTabBar() {
        // Create the Home View Controller
        let homeVC = HomeViewController(viewModel: viewModel)
        homeVC.title = "Home"
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))

        // Create the Bookmarked View Controller
        let bookmarkedVC = BookMarkedViewController(viewModel: viewModel)
        bookmarkedVC.title = "Bookmarked"
        bookmarkedVC.tabBarItem = UITabBarItem(title: "Bookmarked", image: UIImage(systemName: "bookmark"), selectedImage: UIImage(systemName: "bookmark.fill"))
        bookmarkedVC.tabBarItem.badgeColor = .white // Set badge color

        // Create a navigation controller for each view controller
        let homeNavController = UINavigationController(rootViewController: homeVC)
        let bookmarkedNavController = UINavigationController(rootViewController: bookmarkedVC)
        
        // Set navigation bar appearance for both navigation controllers
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = .black // Set navigation bar background color to black
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white] // Set title color to white
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white] //set large title color
        homeNavController.navigationBar.standardAppearance = navBarAppearance
        homeNavController.navigationBar.scrollEdgeAppearance = navBarAppearance
        homeNavController.navigationBar.compactAppearance = navBarAppearance //for iphone small devices
        
        bookmarkedNavController.navigationBar.standardAppearance = navBarAppearance
        bookmarkedNavController.navigationBar.scrollEdgeAppearance = navBarAppearance
        bookmarkedNavController.navigationBar.compactAppearance = navBarAppearance
       

        viewControllers = [homeNavController, bookmarkedNavController]

        // Set tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .black // Set tab bar background color to black
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white] //set the color for the text when selected
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.lightGray]  //set the color for the text when not selected.
        tabBar.standardAppearance = tabBarAppearance
        tabBar.scrollEdgeAppearance = tabBarAppearance
        tabBar.isTranslucent = false // Ensure it's not translucent
        
        // Set the selected image tint color to white.  This affects the image itself.
        tabBar.tintColor = .white
        // Set the unselected image tint color to lightGray
        tabBar.unselectedItemTintColor = .lightGray
    }
}
