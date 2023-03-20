import Combine
import ComposableArchitecture
import MapKit

extension DependencyValues {
    public var localSearchCompleter: LocalSearchCompleter {
        get { self[LocalSearchCompleter.self] }
        set { self[LocalSearchCompleter.self] = newValue }
    }
}

public struct LocalSearchCompleter {
    var completions: () -> EffectPublisher<Result<[LocalSearchCompletion], Error>, Never>
    var search: (String) -> Effect<Never>
}

extension LocalSearchCompleter: DependencyKey {
    public static var liveValue: Self {
        class Delegate: NSObject, MKLocalSearchCompleterDelegate {
            let subscriber: EffectPublisher<Result<[LocalSearchCompletion], Error>, Never>.Subscriber
            
            init(subscriber: EffectPublisher<Result<[LocalSearchCompletion], Error>, Never>.Subscriber) {
                self.subscriber = subscriber
            }
            
            func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
                self.subscriber.send(
                    .success(
                        completer.results
                            .map(LocalSearchCompletion.init(rawValue:))
                    )
                )
            }
            
            func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
                self.subscriber.send(.failure(error))
            }
        }
        
        let completer = MKLocalSearchCompleter()
        
        return Self(
            completions: {
                EffectTask.run { subscriber in
                    let delegate = Delegate(subscriber: subscriber)
                    completer.delegate = delegate
                    
                    return AnyCancellable {
                        _ = delegate
                    }
                }
            },
            search: { queryFragment in
                    .fireAndForget {
                        completer.queryFragment = queryFragment
                    }
            }
        )
    }
}

public struct LocalSearchCompletion: Equatable, Identifiable {
    let rawValue: MKLocalSearchCompletion?
    public let id = UUID()
    var subtitle: String
    var title: String
    
    init(rawValue: MKLocalSearchCompletion) {
        self.rawValue = rawValue
        self.subtitle = rawValue.subtitle
        self.title = rawValue.title
    }
    
    init(subtitle: String, title: String) {
        self.rawValue = nil
        self.subtitle = subtitle
        self.title = title
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.subtitle == rhs.subtitle
        && lhs.title == rhs.title
    }
}
