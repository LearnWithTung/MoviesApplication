//
//  WeakRefVirtualProxy.swift
//  TheMovieDBiOS
//
//  Created by Tung Vu on 04/07/2021.
//

import Foundation

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}
