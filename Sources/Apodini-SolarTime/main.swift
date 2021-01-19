import Foundation
import Apodini
import SolarTime
import class Vapor.HTTPClient

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

    struct SolarDateLocation: Handler {
        @Parameter var location: String
        @Parameter var date: Date?
        var event: Event

        enum Event {
            case sunrise
            case sunset
            case zenith
        }

        struct GeoResponse: Codable {
            let latitude: Double
            let longitude: Double
        }

        func handle() -> Date? { // FIXME: this should be EventLoopFurure<Date>
            let client = Vapor.HTTPClient(eventLoopGroupProvider: .createNew)
            guard let response = try? client.post(url: "https://geocode.xyz", body: .string("locate=\"\(location)\"geoit=\"json\"")).wait() else { fatalError() }
            guard let body = response.body, response.status == .ok else { fatalError() }
            guard let geocode = try? body.getJSONDecodable(GeoResponse.self, at: 0, length: body.readableBytes) else { fatalError() }

            let solarTime = SolarTime(latitude: Angle(value: geocode.latitude, unit: .degrees),
                                      longitude: Angle(value: geocode.longitude, unit: .degrees),
                                      for: date ?? Date())

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
        Group("location") {
            Group("sunrise") {
                SolarDateLocation(event: .sunrise)
            }
            // TODO: geo code from ip
            // curl -X POST -d locate="129.187.212.235" \
            // -d geoit="XML" \
            // https://geocode.xyz
        }
    }
}

try SolarTimeWebService.main()
