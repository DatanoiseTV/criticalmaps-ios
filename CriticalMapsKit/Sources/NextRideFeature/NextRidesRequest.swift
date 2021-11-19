import ApiClient
import CoreLocation
import SharedModels

enum NextRideQueryKeys {
  static let centerLatitude = "centerLatitude"
  static let centerLongitude = "centerLongitude"
  static let radius = "radius"
  static let year = "year"
  static let month = "month"
}

public struct NextRidesRequest: APIRequest {
  
  public typealias ResponseDataType = [Ride]
  public var endpoint = Endpoint(
    baseUrl: Endpoints.criticalmassInEndpoint,
    path: "/api/ride"
  )
  public var headers: HTTPHeaders?
  public var httpMethod: HTTPMethod = .get
  public var queryItems: [URLQueryItem]?
  public var body: Data?
  
  init(coordinate: Coordinate, radius: Int, date: () -> Date = Date.init) {
    queryItems = [
      URLQueryItem(name: NextRideQueryKeys.centerLongitude, value: String(coordinate.longitude)),
      URLQueryItem(name: NextRideQueryKeys.centerLatitude, value: String(coordinate.latitude)),
      URLQueryItem(name: NextRideQueryKeys.radius, value: String(radius)),
      URLQueryItem(name: NextRideQueryKeys.year, value: String(Date.getCurrent(\.year, date))),
    ]
  }
  
  public var decoder: JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }
}
