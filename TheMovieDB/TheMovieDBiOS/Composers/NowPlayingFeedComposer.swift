//
//  NowPlayingFeedComposer.swift
//  TheMovieDBiOS
//
//  Created by Tung Vu on 02/07/2021.
//

import Foundation
import TheMovieDB

public class NowPlayingFeedComposer {
    
    public static func viewControllerComposedWith(feedLoader: NowPlayingLoader, imageLoader: MovieImageDataLoader) -> NowPlayingFeedViewController {
        let refreshController = NowPlayingRefreshController(loader: feedLoader)
        let viewController = NowPlayingFeedViewController(refreshController: refreshController)
        
        refreshController.onRefresh = adaptCellControllers(from: viewController, and: imageLoader)
        
        return viewController
    }
    
    private static func adaptCellControllers(from viewController: NowPlayingFeedViewController, and loader: MovieImageDataLoader) -> (NowPlayingFeed) -> Void{
        {[weak viewController] feed in
            viewController?.cellControllers = feed.items.map {
                NowPlayingItemController(model: $0,
                                         imageLoader: MainQueueDispatchDecorator(decoratee: loader))
                
            }
        }
    }
}

public final class MainQueueDispatchDecorator<T> {

  private(set) public var decoratee: T

  public init(decoratee: T) {
    self.decoratee = decoratee
  }

  public func dispatch(completion: @escaping () -> Void) {
    guard Thread.isMainThread else {
      return DispatchQueue.main.async(execute: completion)
    }

    completion()
  }
}



extension MainQueueDispatchDecorator: MovieImageDataLoader where T == MovieImageDataLoader {
    
    public func load(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> MovieImageDataTask {
        decoratee.load(from: url) { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
    
    
}
