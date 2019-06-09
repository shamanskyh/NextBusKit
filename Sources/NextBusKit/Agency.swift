//
//  Agency.swift
//  NextBusKit
//
//  Created by Harry Shamansky on 3/12/17.
//  Copyright © 2017 Harry Shamansky. All rights reserved.
//

import Foundation
import Kanna

/// A public transit agency
public class Agency: Codable {
    
    // MARK: - Public Properties
    
    /// A unique identifier for the transit agency
    public let tag: String
    
    /// The agency's title
    public let title: String
    
    /// If provided, a shorter title for the agency
    public let shortTitle: String?
    
    /// The name of the region
    public let regionTitle: String
    
    /// Set to `true` to refresh network data when requested instead of using the cached version
    public var needsRefresh = false
    
    // MARK: - Public Functions
    
    /// An array of the agency's routes. First call downloads and parses routes from the server;
    /// successive calls use a cached version.
    public func routes() throws -> [Route] {
        //struct Cached { static var routes = [Route]() }

        /// short circuit if cached routes are okay
        // TODO: Fix route caching
//        if !Cached.routes.isEmpty && !needsRefresh {
//            return Cached.routes
//        }
        
        // get the route list using the tag
        let routeListURLString = Constants.nextBusAPIRoot + Constants.routeListCommand + Constants.agencyParameter + self.tag
        if let routeURL = URL(string: routeListURLString), let routes = try? XML(url: routeURL, encoding: .utf8).css("body > route") {
            var returnRoutes = [Route]()
            for route in routes {
                if let routeTag = route["tag"], let routeTitle = route["title"] {
                    returnRoutes.append(Route(agency: self,
                                              routeTag: routeTag,
                                              routeTitle: routeTitle,
                                              shortTitle: route["shortTitle"]))
                } else {
                    throw Error.parseError
                }
            }
            //Cached.routes = returnRoutes
            //returnRoutes.forEach{ routeCache[$0.tag] = $0 }
            return returnRoutes
        } else {
            throw Error.downloadError
        }
    }
    
    // MARK: - Private Variables
    //internal var routeCache = [String: Route]()
    //internal var stopCache = [String: Stop]()
    //internal var directionCache = [String: Direction]()
    
    // MARK: - Initializers
    
    /// Initializes a new transit agency
    ///
    /// - Parameters:
    ///   - tag: The agency's identifier
    ///   - title: The agency's formal title
    ///   - shortTitle: The agency's short title
    ///   - regionTitle: The region title
    public init(tag: String, title: String, shortTitle: String? = nil, regionTitle: String) {
        self.tag = tag
        self.title = title
        self.shortTitle = shortTitle
        self.regionTitle = regionTitle
        self.needsRefresh = false
    }
}
