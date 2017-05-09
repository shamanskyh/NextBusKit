# NextBusKit
A simple API wrapper in Swift for NextBus transit information.

## Examples
Initialize a transit `Agency`:
```swift
let agency = Agency(tag: "sf-muni", title: "San Francisco Municipal Railway", regionTitle: "California-Northern")
```

Get an `Agency`'s routes:
```swift
do {
    let nJudah = try agency.routes().filter({ $0.tag == "N" })
} catch {
    fatalError()
}
```

Get `Prediction`s for a `Stop`:
```swift
do {
    let powellOutbound = Stop(agency: agency, stopTag: "6995", title: "Powell Station Outbound", location: (37.7843, -122.4078199), stopId: "16995")
    let (predictions, _) = try powellOutbound.predictions()
} catch {
    fatalError()
}
```

## Important Notes
Unless otherwise marked, calls should be assumed to be synchronous. It's a good idea to dispatch to a background queue, query routes/stops, then dispatch back to main when you're ready to update your UI.
