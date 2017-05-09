//
//  Error.swift
//  NextBusKit
//
//  Created by Harry Shamansky on 3/12/17.
//  Copyright © 2017 Harry Shamansky. All rights reserved.
//

/// NextBusKit-specific errors
public enum Error: Swift.Error {
    
    /// The requested content could not be downloaded from the server
    case downloadError
    
    /// The requested attribute could not be parsed from the xml retrieved
    case parseError
    
    /// The request was malformed
    case requestError(String)
}
