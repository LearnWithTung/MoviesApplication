//
//  MainQueueDispatchDecorator.swift
//  TheMovieDBiOS
//
//  Created by Tung Vu on 02/07/2021.
//

import Foundation
import TheMovieDB

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
    public func load(from url: URL, completion: @escaping (MovieImageDataLoader.Result) -> Void) -> MovieImageDataTask {
        decoratee.load(from: url) { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}


extension MainQueueDispatchDecorator: NowPlayingLoader where T == NowPlayingLoader {
    public func load(query: NowPlayingQuery, completion: @escaping (NowPlayingLoader.Result) -> Void) {
        decoratee.load(query: query) { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}
