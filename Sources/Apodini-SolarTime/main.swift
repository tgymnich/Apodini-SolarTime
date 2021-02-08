import Foundation
import SolarTime
import Apodini
import ApodiniREST
import ApodiniOpenAPI
import AsyncHTTPClient

let client = HTTPClient(eventLoopGroupProvider: .createNew)

struct SolarTimeWebService: Apodini.WebService {
    @PathParameter
    var location: String

    var content: some Component {
        SolarDateHandler()
        Group($location) {
            SolarDateLocationHandler(location: $location)
        }
    }

    var configuration: Configuration {
        HTTPConfiguration()
        ExporterConfiguration()
            .exporter(RESTInterfaceExporter.self)
            .exporter(OpenAPIInterfaceExporter.self)
    }
}

try SolarTimeWebService.main()
