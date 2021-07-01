//
//  Credential.swift
//  TheMovieDB
//
//  Created by Tung Vu on 01/07/2021.
//

import Foundation

public struct Credential {
    public let apiKey: String
    
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
}
