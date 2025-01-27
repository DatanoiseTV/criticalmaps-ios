import Combine
import Foundation
import Network

public extension PathMonitorClient {
  static let satisfied = Self(
    networkPathPublisher: Just(NetworkPath(status: .satisfied))
      .eraseToAnyPublisher()
  )

  static let unsatisfied = Self(
    networkPathPublisher: Just(NetworkPath(status: .unsatisfied))
      .eraseToAnyPublisher()
  )

  static let flakey = Self(
    networkPathPublisher: Timer.publish(every: 2, on: .main, in: .default)
      .autoconnect()
      .scan(.satisfied) { status, _ in
        status == .satisfied ? .unsatisfied : .satisfied
      }
      .map { NetworkPath(status: $0) }
      .eraseToAnyPublisher()
  )
}
