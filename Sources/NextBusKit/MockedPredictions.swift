//
//  MockedPredictions.swift
//  NextBusKit
//
//  Created by Harry Shamansky on 11/20/18.
//  Copyright © 2018 Harry Shamansky. All rights reserved.
//

import Foundation

internal class MockedPredictions {
    
    let alerts = [Alert(text: "This is a really long alert for OB svc to POWL. The text should split over a couple of lines because this alert is so long. It is a very very long alert. It's gonna take up many many lines because of how long it is.", priority: .normal), Alert(text: "This is also a really long alert. The text should split over a couple of lines because this alert is so long. It is a very very long alert. It's gonna take up many many lines because of how long it is.", priority: .normal)]
    
    var predictions: [PredictionOrNoPrediction] {
        let agency = Agency(tag: "sf-muni",
                            title: "San Francisco Municipal Railway",
                            shortTitle: "SF Muni",
                            regionTitle: "California-Northern")
        let route = Route(agency: agency,
                          routeTag: "N",
                          routeTitle: "N-Judah")
        let prediction = Prediction(route: route,
                                    strongRoute: route,
                                    predictedTime: Date(timeIntervalSinceNow: 120),
                                    departure: false,
                                    direction: Direction(name: "Outbound", tag: "N_O_1", title: "Outbound to Ocean Beach", active: true, orderedStops:[]),
                                    block: "123",
                                    tripTag: "NOO",
                                    affectedByLayover: false,
                                    scheduleBased: false,
                                    delayed: false,
                                    numberOfVehicles: 2)
        return [PredictionOrNoPrediction.prediction(prediction)]
    }
    
}
