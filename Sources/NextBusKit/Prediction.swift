//
//  Prediction.swift
//  NextBusKit
//
//  Created by Harry Shamansky on 3/12/17.
//  Copyright © 2017 Harry Shamansky. All rights reserved.
//

import Foundation

/// A way to indicate a lack of a prediction
public enum PredictionOrNoPrediction {
    /// A prediction
    case prediction(Prediction)
    /// No prediction
    case noPrediction(NoPrediction)
}

/// A way to indicate that a route is present, but has no prediction
public struct NoPrediction: Codable {
    /// The route
    public weak var route: Route?
    
    public var strongRoute: Route?
    
    /// The title of the direction. Note: This is not a direction object, because not enough
    /// information is known
    public let directionTitle: String
}

/// An estimate for when a vehicle will arrive for a given stop.
public struct Prediction: Codable {
    
    /// The route associated with the prediction
    public weak var route: Route?
    
    public var strongRoute: Route?
    
    /// The predicted time
    public let predictedTime: Date
    
    /// specifies whether the time given refers to when the vehicle will *depart*
    public let departure: Bool
    
    /// The direction for the prediction
    public let direction: Direction
    
    /// The block number associated with the prediction. Given as a string.
    public let block: String?
    
    /// The trip tag. An identifier for a particular trip within a block assignment.
    public let tripTag: String?
    
    /// Whether or not the prediction involves a layover (where the vehicle has not left its
    /// departing terminal yet). If true, the prediction will be less accurate.
    public let affectedByLayover: Bool
    
    /// Whether or not the prediction is purely based on the route schedule and doesn't take GPS
    /// data into account. Only used for certain agencies. If true, the prediction will be less
    /// accurate.
    public let scheduleBased: Bool
    
    /// Whether or not the vehicle is delayed because of traffic. Only used for certain agencies.
    public let delayed: Bool
    
    /// How many vehicles are part of the prediction, if the route's vehicle is capable of running
    public let numberOfVehicles: UInt
}

