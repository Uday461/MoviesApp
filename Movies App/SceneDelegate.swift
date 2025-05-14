//
//  SceneDelegate.swift
//  Movies App (Inshorts)
//
//  Created by Banavath UdayKiran Naik on 09/05/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var viewModel: MoviesViewModelProtocol? = nil

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let networkManager = NetworkManager()
        let movieService = MovieService(networkManager: networkManager)
        let imageService = ImageService(networkManager: networkManager)
        let movieManager = MovieManager(movieService: movieService, imageService: imageService)
        viewModel = MoviesViewModel(movieManager: movieManager)
        
        if let viewModel = viewModel {
            let mainTabBarController = MainTabBarController(viewModel: viewModel)
            
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = mainTabBarController
            self.window = window
            window.makeKeyAndVisible()
        }
 
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let urlContext = URLContexts.first {
            handleDeepLink(url: urlContext.url)
        }
    }
    
    private func handleDeepLink(url: URL) {
        let pathComponents = url.pathComponents
        print("Path Components: \(pathComponents)")
        let movieID = Int(pathComponents[1])
        print(movieID)
        if pathComponents.count == 2, let movieId = Int(pathComponents[1]) {
            navigateToMovieDetails(movieId: movieId)
        }
    }
    
    private func navigateToMovieDetails(movieId: Int) {
        guard let window = window,
              let tabBarController = window.rootViewController as? MainTabBarController,
              let viewModel = viewModel else { return }
        
        if let navControllers = tabBarController.viewControllers {
            for (index, controller) in navControllers.enumerated() {
                if let navController = controller as? UINavigationController,
                   navController.viewControllers.first is HomeViewController {
                    tabBarController.selectedIndex = index
                    
                    let detailedVC = DetailedMovieViewController(viewModel: viewModel)
                    detailedVC.movie = viewModel.fetchMovieById(movieId: movieId)
                    
                    DispatchQueue.main.async {
                        navController.pushViewController(detailedVC, animated: true)
                    }
                    break
                }
            }
        }
    }


    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

