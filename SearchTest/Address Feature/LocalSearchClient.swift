import ComposableArchitecture
import MapKit

extension DependencyValues {
    public var localSearch: LocalSearchClient {
        get { self[LocalSearchClient.self] }
        set { self[LocalSearchClient.self] = newValue }
    }
}

public struct CoordinateRegion: Equatable {
  var center = LocationCoordinate2D()
  var span = CoordinateSpan()
}

extension CoordinateRegion {
  init(rawValue: MKCoordinateRegion) {
    self.init(
      center: .init(rawValue: rawValue.center),
      span: .init(rawValue: rawValue.span)
    )
  }

  var rawValue: MKCoordinateRegion {
    .init(center: self.center.rawValue, span: self.span.rawValue)
  }
}

public struct LocationCoordinate2D: Equatable {
  var latitude: CLLocationDegrees = 0
  var longitude: CLLocationDegrees = 0
}

extension LocationCoordinate2D {
  init(rawValue: CLLocationCoordinate2D) {
    self.init(latitude: rawValue.latitude, longitude: rawValue.longitude)
  }

  var rawValue: CLLocationCoordinate2D {
    .init(latitude: self.latitude, longitude: self.longitude)
  }
}

public struct CoordinateSpan: Equatable {
  var latitudeDelta: CLLocationDegrees = 0
  var longitudeDelta: CLLocationDegrees = 0
}

extension CoordinateSpan {
  init(rawValue: MKCoordinateSpan) {
    self.init(latitudeDelta: rawValue.latitudeDelta, longitudeDelta: rawValue.longitudeDelta)
  }

  var rawValue: MKCoordinateSpan {
    .init(latitudeDelta: self.latitudeDelta, longitudeDelta: self.longitudeDelta)
  }
}

public struct LocalSearchClient {
   public var search: @Sendable (_ completion: LocalSearchCompletion) async throws -> Response

  public struct Response: Equatable {
    var boundingRegion = CoordinateRegion()
    var mapItems: [MKMapItem] = []
  }
}

extension LocalSearchClient.Response {
  init(rawValue: MKLocalSearch.Response) {
    self.boundingRegion = .init(rawValue: rawValue.boundingRegion)
    self.mapItems = rawValue.mapItems
  }
}

extension LocalSearchClient: DependencyKey {
   public static let liveValue: Self = {
        
       
       return Self(
        search: { completion in
            
            Response.init(rawValue:
                            try await MKLocalSearch(request: .init(completion: completion.rawValue!))
                .start())
            
        }
       )
   }()
}
