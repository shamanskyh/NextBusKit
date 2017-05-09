//
//  Prediction.swift
//  NextBusKit
//
//  Created by Harry Shamansky on 3/12/17.
//  Copyright © 2017 Harry Shamansky. All rights reserved.
//

import Foundation

/// An estimate for when a vehicle will arrive for a given stop.
public struct Prediction {

    /// The route associated with the prediction
    weak var route: Route?
    
    /// The predicted time
    let predictedTime: Date
    
    /// specifies whether the time given refers to when the vehicle will *depart*
    let departure: Bool
    
    /// The direction for the prediction
    let direction: Direction
    
    /// The block number associated with the prediction. Given as a string.
    let block: String?
    
    /// The trip tag. An identifier for a particular trip within a block assignment.
    let tripTag: String?
    
    /// Whether or not the prediction involves a layover (where the vehicle has not left its
    /// departing terminal yet). If true, the prediction will be less accurate.
    let affectedByLayover: Bool
    
    /// Whether or not the prediction is purely based on the route schedule and doesn't take GPS
    /// data into account. Only used for certain agencies. If true, the prediction will be less
    /// accurate.
    let scheduleBased: Bool
    
    /// Whether or not the vehicle is delayed because of traffic. Only used for certain agencies.
    let delayed: Bool
    
    /// How many vehicles are part of the prediction, if the route's vehicle is capable of running
    let numberOfVehicles: UInt
}
