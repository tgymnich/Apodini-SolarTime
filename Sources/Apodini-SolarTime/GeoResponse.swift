//
//  GeoResponse.swift
//  
//
//  Created by Tim Gymnich on 8.2.21.
//

import Foundation

enum GeoResponseDecodingError: Swift.Error {
    case errorDecodingCoordinates
}

struct GeoResponse: Decodable {
    let latitude: Double
    let longitude: Double

    enum CodingKeys: String, CodingKey {
        case latitude = "latt"
        case longitude = "longt"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitudeString = try container.decode(String.self, forKey: .latitude)
        guard let latitude = Double(latitudeString) else { throw GeoResponseDecodingError.errorDecodingCoordinates }
        let longitudeString = try container.decode(String.self, forKey: .longitude)
        guard let longitude = Double(longitudeString) else { throw GeoResponseDecodingError.errorDecodingCoordinates }

        self.latitude = latitude
        self.longitude = longitude
    }
}
