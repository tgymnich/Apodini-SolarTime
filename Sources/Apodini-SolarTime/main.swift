import Foundation
import Apodini
import SolarTime

struct SolarTimeWebService: Apodini.WebService {

    struct SolarDate: Handler {
        @Parameter var latitude: Double
        @Parameter var longitude: Double
        @Parameter var date: Date?
        var event: Event

        enum Event {
            case sunrise
            case sunset
            case zenith
        }

        func handle() -> Date? {
            let solarTime = SolarTime(latitude: Angle(value: latitude, unit: .degrees), longitude: Angle(value: longitude, unit: .degrees), for: date ?? Date())

            switch event {
            case .sunrise:
                return solarTime.sunrise()
            case .sunset:
                return solarTime.sunset()
            case .zenith:
                return solarTime.zenith()
            }
        }
    }

    struct SolarAngle: Handler {
        @Parameter var latitude: Double
        @Parameter var longitude: Double
        @Parameter var date: Date?

        func handle() -> Angle? {
            let solarTime = SolarTime(latitude: Angle(value: latitude, unit: .degrees), longitude: Angle(value: longitude, unit: .degrees), for: date ?? Date())

            return solarTime.solarDeclination
        }
    }


    var content: some Component {
        Group("sunrise") {
            SolarDate(event: .sunrise)
        }
        Group("sunset") {
            SolarDate(event: .sunset)
        }
        Group("zenith") {
            SolarDate(event: .zenith)
        }
        Group("solarDeclination") {
            SolarAngle()
        }
        Group("duration") {
            Group("daylight") {
                Text("Hello World! 👋")
            }
        }
    }
}

try SolarTimeWebService.main()
