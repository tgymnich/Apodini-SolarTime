//
//  SolarDate.swift
//
//
//  Created by Tim Gymnich on 8.2.21.
//

import Foundation
import SolarTime
import Apodini

enum SolarDateHandlerError: Swift.Error {
    case cannotDecodeGeoResponse
    case missingGeoResponse
    case missingIPAddress
}

struct SolarDateRespone: ResponseTransformable, Codable {
    let sunrise: String?
    let sunset: String?
    let zenith: String?
    let currentDeclination: Double

    let hoursOfSunlight: Double

    init(_ solar: SolarTime) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        if let sunriseDate = solar.sunrise() {
            self.sunrise = dateFormatter.string(from: sunriseDate)
        } else {
            self.sunrise = "no sunrise"
        }

        if let sunsetDate = solar.sunset() {
            self.sunset = dateFormatter.string(from: sunsetDate)
        } else {
            self.sunset = "no sunset"
        }

        if let zenithDate = solar.zenith() {
            self.zenith = dateFormatter.string(from: zenithDate)
        } else {
            self.zenith = "no zenith"
        }

        if let sunriseDate = solar.sunrise(), let sunsetDate = solar.sunset() {
            self.hoursOfSunlight = sunriseDate.distance(to: sunsetDate) / 60 / 60
        } else {
            self.hoursOfSunlight = 0
        }

        self.currentDeclination = abs(solar.solarDeclination.converted(to: .degrees).value)
    }
}

struct SolarDateHandler: Handler {
    @Parameter var latitude: Double?
    @Parameter var longitude: Double?
    @Parameter var date: Date?
    @Environment(\.connection) var connection: Connection

    func handle() throws -> EventLoopFuture<SolarDateRespone> {
        if let latitude = latitude, let longitude = longitude {
            let solarTime = SolarTime(
                latitude: Angle(value: latitude, unit: .degrees),
                longitude: Angle(value: longitude, unit: .degrees),
                for: date ?? Date()
            )
            return connection.eventLoop.makeSucceededFuture(SolarDateRespone(solarTime))
        } else if let address = connection.remoteAddress?.ipAddress  {
            return client.post(url: "https://geocode.xyz", body: .string("locate=\(address)&geoit=json"))
                .map { $0.body }
                .unwrap(orError: SolarDateHandlerError.missingGeoResponse )
                .flatMapThrowing { try $0.getJSONDecodable(GeoResponse.self, at: 0, length: $0.readableBytes) }
                .unwrap(orError: SolarDateHandlerError.cannotDecodeGeoResponse)
                .map { georesponse -> SolarDateRespone in
                    let solarTime = SolarTime(
                        latitude: Angle(value: georesponse.latitude, unit: .degrees),
                        longitude: Angle(value: georesponse.longitude, unit: .degrees),
                        for: date ?? Date()
                    )
                    return SolarDateRespone(solarTime)
                }
        } else {
            throw SolarDateHandlerError.missingIPAddress
        }
    }
}

struct SolarDateLocationHandler: Handler {
    @Parameter var location: String
    @Parameter var date: Date?

    func handle() -> EventLoopFuture<SolarDateRespone> {
        return client.post(url: "https://geocode.xyz", body: .string("locate=\(location)&geoit=json"))
            .map { $0.body }
            .unwrap(orError: SolarDateHandlerError.missingGeoResponse )
            .flatMapThrowing { try $0.getJSONDecodable(GeoResponse.self, at: 0, length: $0.readableBytes) }
            .unwrap(orError: SolarDateHandlerError.cannotDecodeGeoResponse)
            .map { georesponse -> SolarDateRespone in
                let solarTime = SolarTime(
                    latitude: Angle(value: georesponse.latitude, unit: .degrees),
                    longitude: Angle(value: georesponse.longitude, unit: .degrees),
                    for: date ?? Date()
                )
                return SolarDateRespone(solarTime)
            }
    }
}

