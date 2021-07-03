//
//  SceneDelegate.swift
//  TheMovieDBiOSApp
//
//  Created by Tung Vu on 02/07/2021.
//

import UIKit
import TheMovieDB
import TheMovieDBiOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private lazy var navController = UINavigationController()

    private lazy var baseURL = URL(string: "https://api.themoviedb.org/3/movie/now_playing")!
    private lazy var credential = Credential(apiKey: "494d9fe55bdb97bc7ee0b57dfa80751b")
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)

        navController.setViewControllers([makeNowPlayingScene()], animated: true)
        window.rootViewController = navController

        self.window = window
        self.window?.makeKeyAndVisible()
    }
    
    func makeNowPlayingScene() -> NowPlayingFeedViewController {
        let client = URLSessionHTTPClient(session: .init(configuration: .ephemeral))
        let authenticatedClient = AuthenticatedHTTPClientDecorator(decoratee: client, credential: credential)
        
        let loader = RemoteNowPlayingFeedLoader(url: baseURL, client: authenticatedClient)
        let imageLoader = RemoteMovieImageDataLoader(client: client)
        
        let viewController = NowPlayingFeedComposer.viewControllerComposedWith(feedLoader: loader, imageLoader: imageLoader)
        viewController.title = "Now Playing"
        
        return viewController
    }

}

