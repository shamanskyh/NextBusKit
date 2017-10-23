//
//  Route.swift
//  NextBusKit
//
//  Created by Harry Shamansky on 3/12/17.
//  Copyright © 2017 Harry Shamansky. All rights reserved.
//

import Foundation
import Kanna

/// A public transportation route. Routes can go in multiple directions (inbound, outbound, etc.)
/// and have a set of stops associated with them.
public final class Route {
    
    // MARK: - Public Properties
    
    /// A unique identifier (within the agency) for the route.
    /// For most agencies, this is the short form of the route's name (e.g. `30` or `N`).
    public let tag: String
    
    /// The full title of the route (e.g. `30-Stockton` or `N-Judah`).
    public let title: String
    
    /// A short title for the route. Useful when space is limited. Only used by certain agencies.
    public let shortTitle: String?
    
    /// Set to `true` to refresh network data when requested instead of using the cached version
    public var needsRefresh = false
    
    // MARK: - Public Functions

    /// Returns details about the routes, using a cached version if the API request has already been
    /// made.
    ///
    /// - Parameter showInactiveDirections: Whether or not all route directions should be requested. 
    ///   `false` by default
    /// - Returns: detailed information about the route
    /// - Throws: Can throw a parse or download error, as this requires an additional API call
    public func details(showInactiveDirections: Bool = false) throws -> RouteDetails {
        struct Cached { static var details: RouteDetails? = nil }
        
        if let cachedDetails = Cached.details, !needsRefresh {
            return cachedDetails
        }
        
        // get the route config using the tag
        let routeConfigURLString = Constants.nextBusAPIRoot + Constants.routeConfigCommand + Constants.agencyParameter + agencyTag + Constants.routeParameter + tag + (showInactiveDirections ? Constants.verboseRouteParameter : "")
        
        guard let url = URL(string: routeConfigURLString),
            let document = try? XML(url: url, encoding: .utf8),
            let route = document.css("body > route").first else {
                throw Error.downloadError
        }
        
        guard let colorString = route["color"],
            let oppositeColorString = route["oppositeColor"],
            let latMin = route["latMin"],
            let latMax = route["latMax"],
            let lonMin = route["lonMin"],
            let lonMax = route["lonMax"],
            let latMinDouble = Double(latMin),
            let latMaxDouble = Double(latMax),
            let lonMinDouble = Double(lonMin),
            let lonMaxDouble = Double(lonMax) else {
            throw Error.parseError
        }
        
        var stops = [String: Stop]()
        for stop in document.css("body > route > stop") {
            if let tag = stop["tag"],
                let title = stop["title"],
                let stopId = stop["stopId"],
                let lat = stop["lat"],
                let lon = stop["lon"],
                let latDouble = Double(lat),
                let lonDouble = Double(lon) {
                let completeStop = (agency != nil) ? Stop(agency: agency!, stopTag: tag, title: title, shortTitle: stop["shortTitle"], location: (latDouble, lonDouble), stopId: stopId) : Stop(agencyTag: agencyTag, stopTag: tag, title: title, shortTitle: stop["shortTitle"], location: (latDouble, lonDouble), stopId: stopId)
                stops[tag] = completeStop
                agency?.stopCache[tag] = completeStop
            } else {
                throw Error.parseError
            }
        }

        var directions = [Direction]()
        for direction in document.css("body > route > direction") {
            if let tag = direction["tag"],
                let name = direction["name"],
                let title = direction["title"],
                let active = direction["useForUI"] {

                let orderedStops: [Stop] = direction.css("stop").flatMap({ $0["tag"] }).flatMap({ stops[$0] })
                let completeDirection = Direction(name: name,
                                                  tag: tag,
                                                  title: title,
                                                  active: active == "true",
                                                  orderedStops: orderedStops)
                directions.append(completeDirection)
                agency?.directionCache[tag] = completeDirection
            } else {
                throw Error.parseError
            }
        }
        
        let details = RouteDetails(colorString: colorString,
                                   oppositeColorString: oppositeColorString,
                                   bounds: RouteArea(latMin: latMinDouble,
                                                     latMax: latMaxDouble,
                                                     lonMin: lonMinDouble,
                                                     lonMax: lonMaxDouble),
                                   directions: directions)
        needsRefresh = false
        Cached.details = details
        return details
    }
    
    // MARK: - Initializer
    
    /// Initializes a Route
    ///
    /// - Parameters:
    ///   - agencyTag: The agency's tag, e.g. `sf-muni`
    ///   - routeTag: The route's tag, e.g. `N`
    ///   - routeTitle: The route's title, e.g. `N-Judah`
    ///   - shortTitle: The route's short title, if applicable
    public init(agencyTag: String,
                routeTag: String,
                routeTitle: String,
                shortTitle: String? = nil) {
        self.agencyTag = agencyTag
        tag = routeTag
        title = routeTitle
        self.shortTitle = shortTitle
    }
    
    /// Convenience initializer to initialize a route with an agency to take advantage of caching
    ///
    /// - Parameters:
    ///   - agency: The transit agency
    ///   - routeTag: The route's tag, e.g. `N`
    ///   - routeTitle: The route's title, e.g. `N-Judah`
    ///   - shortTitle: The route's short title, if applicable
    public convenience init(agency: Agency,
                            routeTag: String,
                            routeTitle: String,
                            shortTitle: String? = nil) {
        self.init(agencyTag: agency.tag,
                  routeTag: routeTag,
                  routeTitle: routeTitle,
                  shortTitle: shortTitle)
        self.agency = agency
    }
    
    // MARK: - Private variables
    fileprivate let agencyTag: String
    fileprivate weak var agency: Agency?
}

/// A representation of route details that require an additional API call
public struct RouteDetails {
    
    /// The route's color
    public let colorString: String
    
    /// A color that contrasts with the route's color
    public let oppositeColorString: String
    
    /// The route's bounding box on a map
    public let bounds: RouteArea
    
    /// An array of the route's possible directions
    public let directions: [Direction]
}

/// A representation of the route's maximum bounds on a map
public struct RouteArea {
    
    /// The minimum latitude of the bounding box
    public let latMin: Double
    
    /// The maximum latitude of the bounding box
    public let latMax: Double
    
    /// The minimum longitude of the bounding box
    public let lonMin: Double
    
    /// The maximum longitude of the bounding box
    public let lonMax: Double
}
