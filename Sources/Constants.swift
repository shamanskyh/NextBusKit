//
//  Constants.swift
//  NextBusKit
//
//  Created by Harry Shamansky on 3/12/17.
//  Copyright © 2017 Harry Shamansky. All rights reserved.
//

/// Constants
public struct Constants {
    
    /// The API root
    static let nextBusAPIRoot = "http://webservices.nextbus.com/service/publicXMLFeed?command="
    
    /// The agency list command
    static let agencyListCommand = "agencyList"
    
    /// The route list command
    static let routeListCommand = "routeList"
    
    /// The route configuration command
    static let routeConfigCommand = "routeConfig"
    
    /// The predictions command
    static let predictionsCommand = "predictions"
    
    /// The key used to pass an agency as a parameter
    static let agencyParameter = "&a="
    
    /// The key used to pass a route as a parameter
    static let routeParameter = "&r="
    
    /// The key used to pass a stop identifier as a parameter
    static let stopIdParameter = "&stopId="
    
    /// The key used to pass a stop tag as a parameter
    static let stopTagParameter = "&s="
    
    /// The key used to request verbose route directions
    static let verboseRouteParameter = "&verbose"
}
