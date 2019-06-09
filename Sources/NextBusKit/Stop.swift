//
//  Stop.swift
//  NextBusKit
//
//  Created by Harry Shamansky on 3/12/17.
//  Copyright © 2017 Harry Shamansky. All rights reserved.
//

import Foundation
import Kanna

public final class Stop: Codable, CustomDebugStringConvertible {
    
    /// A unique alphanumeric identifier for the stop
    public let tag: String
    
    /// The stop's title
    public let title: String
    
    /// A short title for the stop, if available
    public let shortTitle: String?
    
    /// The stop's location
    public let location: Location
    
    /// A numeric identifier for the stop. *Not unique* as some agencies share stop ids across
    /// multiple inbound/outbound stops
    public let stopId: String?
    
    /// Returns predictions for the stop
    ///
    /// - Parameter routes: If specified, will limit the route predictions before making the API
    /// call. If the stop was initialized without a `stopId`, this field must be specified
    /// - Parameter mockedData: If true, the function will returned mocked data without making a
    /// network call
    /// - Parameter printNetworkCalls: If true, the function will print all network calls that it
    /// makes to the console
    /// - Returns: A tuple consisting of an array of predictions (or missing predictions) and any
    /// messages associated with the stop
    /// - Throws: Download or parse errors if the API call fails
    public func predictions(routes: [Route] = [],
                            mockedData: Bool = false,
                            printNetworkCalls: Bool = false) throws -> ([PredictionOrNoPrediction], [Alert]) {

        if mockedData {
            let mock = MockedPredictions()
            return (mock.predictions, mock.alerts)
        }
        
        // handle case where we don't have a stopId
        var predictionsURLString: String!
        if let stopId = stopId, routes.isEmpty {
            if !routes.isEmpty {
                predictionsURLString = Constants.nextBusAPIRoot + Constants.predictionsCommand + Constants.agencyParameter + agencyTag + Constants.stopIdParameter + stopId + Constants.routeParameter + routes.map({ $0.tag }).joined(separator: Constants.routeParameter)
            } else {
                predictionsURLString = Constants.nextBusAPIRoot + Constants.predictionsCommand + Constants.agencyParameter + agencyTag + Constants.stopIdParameter + stopId
            }
        } else if !routes.isEmpty {
            predictionsURLString = Constants.nextBusAPIRoot + Constants.predictionsCommand + Constants.agencyParameter + agencyTag + Constants.stopTagParameter + tag + Constants.routeParameter + routes.map({ $0.tag }).joined(separator: Constants.routeParameter)
        } else {
            throw Error.requestError("Must specify routes for predictions if stopId isn't specified")
        }
        
        guard let url = URL(string: predictionsURLString),
            let document = try? XML(url: url, encoding: .utf8) else {
                throw Error.downloadError
        }
        
        if printNetworkCalls {
            print("NEXTBUS API CALLING: \(url)")
        }
        
        var finalPredictions = [PredictionOrNoPrediction]()
        var finalAlerts = Set<Alert>()
        for outerPredictions in document.css("body > predictions") {
            guard let routeTag = outerPredictions["routeTag"], let routeTitle = outerPredictions["routeTitle"] else {
                throw Error.parseError
            }
            
            // no predictions
            if let dirTitleBecuaseNoPredictions = outerPredictions["dirTitleBecauseNoPredictions"] {
                
                // FIXME: If we don't have a route here, we create one but then it's assigned to
                // a weak var and we lose it
                var useStrongRoute = false
                let route = Route(agencyTag: agencyTag, routeTag: routeTag, routeTitle: routeTitle)
                useStrongRoute = true
//                if agency?.routeCache[routeTag] == nil {
//                    useStrongRoute = true
//                }
                
                let noPrediction = NoPrediction(route: route, strongRoute: useStrongRoute ? route : nil, directionTitle: dirTitleBecuaseNoPredictions)
                finalPredictions.append(PredictionOrNoPrediction.noPrediction(noPrediction))
            }
            
            for direction in outerPredictions.css("direction") {
                guard let directionTitle = direction["title"] else {
                    throw Error.parseError
                }
                
                for directionPrediction in direction.css("prediction") {
                    guard let epochTime = directionPrediction["epochTime"],
                        let epochTimeMilliseconds = Double(epochTime),
                        let directionTag = directionPrediction["dirTag"] else {
                            throw Error.parseError
                    }
                    
                    // FIXME: If we don't have a route here, we create one but then it's assigned to
                    // a weak var and we lose it
                    var useStrongRoute = false
                    let route = Route(agencyTag: agencyTag, routeTag: routeTag, routeTitle: routeTitle)
//                    if agency?.routeCache[routeTag] == nil {
//                        useStrongRoute = true
//                    }
                    useStrongRoute = true
                    
                    let predictedTime = Date(timeIntervalSince1970: epochTimeMilliseconds / 1000.0)
                    let direction = Direction(name: nil, tag: directionTag, title: directionTitle, active: true, orderedStops: [])
                    var numberOfVehicles: UInt = 1
                    if let numberOfVehiclesString = directionPrediction["vehiclesInConsist"],
                        let vehicleCount = UInt(numberOfVehiclesString) {
                        numberOfVehicles = vehicleCount
                    }
                    let prediction = Prediction(route: route,
                                                strongRoute: useStrongRoute ? route : nil,
                                                predictedTime: predictedTime,
                                                departure: directionPrediction["isDeparture"] == "true",
                                                direction: direction,
                                                block: directionPrediction["block"],
                                                tripTag: directionPrediction["tripTag"],
                                                affectedByLayover: directionPrediction["affectedByLayover"] == "true",
                                                scheduleBased: directionPrediction["isScheduleBased"] == "true",
                                                delayed: directionPrediction["delayed"] == "true",
                                                numberOfVehicles: numberOfVehicles)
                    finalPredictions.append(PredictionOrNoPrediction.prediction(prediction))
                }
            }
            
            for message in outerPredictions.css("message") {
                guard let messageText = message["text"] else {
                    throw Error.parseError
                }
                let alert = Alert(text: messageText, priority: AlertPriority.priorityFromString(priority: message["priority"]))
                finalAlerts.insert(alert)
            }
        }
        return (finalPredictions, Array(finalAlerts))
    }
    
    // MARK: Private Variables
    fileprivate let agencyTag: String
    fileprivate weak var agency: Agency?
    
    /// Initializes a transit stop
    ///
    /// - Parameters:
    ///   - agencyTag: The agency's tag, e.g. `sf-muni`
    ///   - stopTag: The stop's tag, for internal use only
    ///   - title: The stop's title, e.g. `Fifth St. & Market St.`
    ///   - shortTitle: The stop's short title for constrained interfaces. e.g. `5th & Market`
    ///   - location: The stop's location, as a coordinate pair
    ///   - stopId: The stop's identifier. Note: This is not necessarily unique, whereas `tag` is.
    public init(agencyTag: String,
                stopTag: String,
                title: String,
                shortTitle: String? = nil,
                location: Location,
                stopId: String? = nil) {
        self.agencyTag = agencyTag
        self.tag = stopTag
        self.title = title
        self.shortTitle = shortTitle
        self.location = location
        self.stopId = stopId
    }
    
    /// Convenience initializer for a stop that takes advantage of the caching associated with an
    /// `Agency` object
    ///
    /// - Parameters:
    ///   - agency: The agency
    ///   - stopTag: The stop's tag, for internal use only
    ///   - title: The stop's title, e.g. `Fifth St. & Market St.`
    ///   - shortTitle: The stop's short title for constrained interfaces. e.g. `5th & Market`
    ///   - location: The stop's location, as a coordinate pair
    ///   - stopId: The stop's identifier. Note: This is not necessarily unique, whereas `tag` is.
    public convenience init(agency: Agency,
                            stopTag: String,
                            title: String,
                            shortTitle: String? = nil,
                            location: Location,
                            stopId: String? = nil) {
        self.init(agencyTag: agency.tag,
                  stopTag: stopTag,
                  title: title,
                  shortTitle: shortTitle,
                  location: location,
                  stopId: stopId)
        self.agency = agency
    }
    
    public var debugDescription: String {
        return self.title
    }
}

extension Stop: Equatable {
    public static func ==(lhs: Stop, rhs: Stop) -> Bool {
        return lhs.agencyTag == rhs.agencyTag && lhs.tag == rhs.tag
    }
}

extension Stop: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(agencyTag)
        hasher.combine(tag)
    }
}

/// A struct representing a geographic point
public struct Location: Codable {

    /// the point's latitude, in degrees
    public let latitude: Double
    
    /// the point's longitude, in degrees
    public let longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

