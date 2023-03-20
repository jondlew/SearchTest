//
//  EventMap.swift
//  Carpool-Kids
//
//  Created by Jonathan Lew on 7/8/21.
//

import SwiftUI
import MapKit
import Contacts
import ComposableArchitecture

public struct CenterPoint: Equatable {
    let lat: Double
    let lng: Double
}

public enum MapViewZoom: Double {
    case close = 500
    case medium = 5000
    case far = 15000
}

public struct MapAddress: Equatable {
    public let name: String?
    public let address_1: String
    public let address_2: String
    public let lat: Double
    public let lng: Double
    
    public init(name: String?, address_1: String, address_2: String, lat: Double, lng: Double) {
        self.name = name
        self.address_1 = address_1
        self.address_2 = address_2
        self.lat = lat
        self.lng = lng
    }
    
    public var address:String {
        address_1 + ", " + address_2
    }
}
struct MapKitAnnotation: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let address: String
    let coordinate: LocationCoordinate2D
}



struct MapAnnotationView: View {
    @State var showInfo = false
    let size = 30.0
    var annotation: MapKitAnnotation
    
    var body: some View {
        VStack(spacing:2) {
            
            Button {
                let addressDict = [CNPostalAddressStreetKey: annotation.address]
                let placemark = MKPlacemark(coordinate: annotation.coordinate.rawValue, addressDictionary: addressDict)
                
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = annotation.name
                
                mapItem.openInMaps(launchOptions: nil)
            }
        label:
            {
                
                ZStack {
                    Circle()
                        .foregroundColor(.black.opacity(0.25))
                        .offset(y: 1.0)
                    Circle()
                        .foregroundColor(.white)
                    Image(systemName: "mappin.circle.fill")
                        .resizable()
                        .foregroundColor(.red)
                }.frame(width: size, height: size, alignment: .center)
                    .buttonStyle(.borderless)
                
                
            }.accentColor(.white)
            
            Text(annotation.name).font(.system(size: 10).weight(.semibold))
        }
        
    }
}

struct MapView: View {
    @State var coordinateRegion: MKCoordinateRegion
    var centerPoint: CenterPoint
    var annotationItems: [MapKitAnnotation]
   
    
    init(centerPoint: CenterPoint, annotationItems: [MapKitAnnotation], zoom:MapViewZoom? = nil) {
       
        self.centerPoint = centerPoint
        self.annotationItems = annotationItems
        self.coordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: centerPoint.lat, longitude: centerPoint.lng), latitudinalMeters: zoom?.rawValue ?? MapViewZoom.far.rawValue, longitudinalMeters: zoom?.rawValue ?? MapViewZoom.far.rawValue)
    }
    
    //TODO ask for permission to use location while app is in use
    
    var body: some View {
        Map(coordinateRegion: $coordinateRegion, showsUserLocation: true, annotationItems: annotationItems) { annotation in
            MapAnnotation(coordinate: annotation.coordinate.rawValue) {
                MapAnnotationView(annotation: annotation)
            }
        }.onChange(of: centerPoint) { centerPoint in
            coordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: centerPoint.lat, longitude: centerPoint.lng), latitudinalMeters: MapViewZoom.close.rawValue, longitudinalMeters:  MapViewZoom.close.rawValue)
        }
    }
}


public enum MapViewSize: CGFloat {
    case small = 140
    case medium = 200
    case large = 280
}

public struct AddressFeature: Reducer {
  public init() {}
    
    public struct State: Equatable {
        var mapAddress: MapAddress?
        var annotations: [MapKitAnnotation]?
        var centerPoint: CenterPoint
        @PresentationState var addressSearch: AddressSearch.State?
       
        public init(mapAddress: MapAddress?) {
            self.mapAddress = mapAddress
            self.centerPoint = CenterPoint(lat: 0.0, lng: 0.0)
//            makeAnnotations(&self)
//            makeCenterPoint(&self)
            
            
//            func makeAnnotations(_ state: inout State) {
//                guard let mapAddress = state.mapAddress else {
//                    return
//                }
//                var annotations: [MapKitAnnotation] = []
//                let locationAnnotation = MapKitAnnotation(name: mapAddress.name ?? mapAddress.address_1, address: mapAddress.address_1, coordinate: LocationCoordinate2D(latitude: mapAddress.lat, longitude: mapAddress.lng))
//                annotations.append(locationAnnotation)
//                state.annotations = annotations
//            }
//
//            func makeCenterPoint(_ state: inout State) {
//                if let mapAddress = state.mapAddress  {
//                    state.centerPoint = CenterPoint(lat: mapAddress.lat, lng: mapAddress.lng)
//                }
//            }
            
        }
        
    }
    
    public enum Action: Equatable {
        case onAppear
        case addressSearch(PresentationAction<AddressSearch.Action>)
        case clearAddressButtonPressed
        case lookupAddressButtonPressed
    }
    
    public var body: some Reducer<State, Action> {
        
        Reduce { state, action in
            switch action {
                
            case .onAppear:
                makeAnnotations(&state)
                makeCenterPoint(&state)
                return .none
                
            case .clearAddressButtonPressed:
                state.mapAddress = nil
                return .none
                
            case .lookupAddressButtonPressed:
                state.addressSearch = AddressSearch.State()
                return .none
                
            case let .addressSearch(.presented(.searchResponse(.success(response)))):
                updateLocation(response: response, &state)
                return .none
                
            case .addressSearch:
                return .none
                
            }
        }
        
        .ifLet(\.$addressSearch, action: /Action.addressSearch) {
            AddressSearch()
        }
    }

    
    func makeAnnotations(_ state: inout State) {
        guard let mapAddress = state.mapAddress else {
            return
        }
        var annotations: [MapKitAnnotation] = []
        let locationAnnotation = MapKitAnnotation(name: mapAddress.name ?? mapAddress.address_1, address: mapAddress.address_1, coordinate: LocationCoordinate2D(latitude: mapAddress.lat, longitude: mapAddress.lng))
        annotations.append(locationAnnotation)
        state.annotations = annotations
    }
    
    func makeCenterPoint(_ state: inout State) {
        if let mapAddress = state.mapAddress  {
            state.centerPoint = CenterPoint(lat: mapAddress.lat, lng: mapAddress.lng)
        }
    }
    
    func updateLocation(response: LocalSearchClient.Response, _ state: inout State) {
        guard let placemark = response.mapItems.first?.placemark,
        let street = placemark.thoroughfare,
        let city = placemark.locality
        else {return}
        
        //Allowing an empty street number for this location just in case
        //the user's home address isn't yet in Maps database. They can
        //at least save the location with a street name.
        //This is for you Tavern Ln, Monrovia MD :-)
        
        let address_1 = "\(placemark.subThoroughfare ?? "") \(street)"
        
        state.mapAddress = MapAddress(name: state.mapAddress?.name, address_1: address_1, address_2: city, lat: placemark.coordinate.latitude, lng: placemark.coordinate.longitude)
        
        makeAnnotations(&state)
        makeCenterPoint(&state)
    }
}
    

public struct AddressFeatureView: View {
    
    let store: StoreOf<AddressFeature>
    public var size: MapViewSize
    public var labelFont: Font
    public var labelOpacity: Double
    public var zoom: MapViewZoom?
   
    
    public init(store: StoreOf<AddressFeature>, size: MapViewSize = .large, labelFont:Font = .subheadline, labelOpacity: Double = 0.75, zoom: MapViewZoom? = nil) {
        self.store = store
        self.size = size
        self.labelFont = labelFont
        self.labelOpacity = labelOpacity
        self.zoom = zoom
    }
    
    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) {
            viewStore in
            
            if let mapAddress = viewStore.state.mapAddress,
               let annotations = viewStore.state.annotations {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Address").font(labelFont).opacity(labelOpacity)
                    HStack {
                        Text(mapAddress.address)
                        Spacer()
                        Button {
                            
                            viewStore.send(.clearAddressButtonPressed, animation: .default)
                            
                        } label: {
                            Image(systemName: "xmark.circle")
                        }.accentColor(.gray)
                            .buttonStyle(BorderlessButtonStyle())
                    }
                    

                    MapView(centerPoint: viewStore.state.centerPoint, annotationItems: annotations, zoom: zoom)
                        .frame(height: size.rawValue)
                        .cornerRadius(8.0)
                        .padding(.top, 8)
                        .buttonStyle(.borderless)
                    
                }.padding(.bottom, 12)
                    .onAppear {
                        viewStore.send(.onAppear)
                    }
            } else {
                HStack(alignment:.center, spacing:4) {
                    Spacer()
                    Button {
                        viewStore.send(.lookupAddressButtonPressed)
                    } label: {
                        //ViewBuilders().blueBorderedButton("Lookup Address")
                        Text("Lookup Address")
                    }.buttonStyle(.borderedProminent)
                    Spacer()
                }.padding()
                    .sheet(store: store.scope(state: \.$addressSearch, action: AddressFeature.Action.addressSearch)) {
                        store in AddressSearchView(store: store)
                    }
                
            }
        }
        
        
    }
    
}


struct Previews_MapView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AddressFeatureView(store: Store(
                initialState: AddressFeature.State(mapAddress: MapAddress(name: "YOLO", address_1: "123 Main Street", address_2: "Ventura", lat: 34.28101, lng: -119.29890)),
                reducer: AddressFeature()
            ))
        }
    }
}
