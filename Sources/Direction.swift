//
//  Direction.swift
//  NextBusKit
//
//  Created by Harry Shamansky on 3/12/17.
//  Copyright © 2017 Harry Shamansky. All rights reserved.
//

/// A struct representing a direction on a route. For instance, the N-Judah has a route named
/// "Outbound to Ocean Beach"
///
/// - Todo: It's unfortunate that the Prediction API call doesn't return better route details. We
///   should be able to cache known directions so they can be reused in the prediction API call.
public struct Direction {
    
    /// The canonical direction used by the agency. E.g. "Inbound" or "Outbound"
    public let name: String?
    
    /// The direction's tag. This shouldn't be shown in UI, but can be used to uniquely identify the
    /// route
    public let tag: String
    
    /// The direction's formal title
    public let title: String
    
    /// Whether or not the direction is currently active; whether it should be shown in the UI
    public let active: Bool
    
    /// An array of ordered stops on the direction
    public let orderedStops: [Stop]
}
