import ComposableArchitecture
import Foundation
import SharedModels
import Styleguide
import SwiftUI
import UIApplicationClient

public struct TwitterFeedView: View {
  public struct TwitterFeedViewState: Equatable {
    public let shouldDisplayPlaceholder: Bool

    public init(_ state: TwitterFeedState) {
      if let tweets = state.contentState.elements {
        shouldDisplayPlaceholder = state.twitterFeedIsLoading && tweets.isEmpty
      } else {
        shouldDisplayPlaceholder = state.twitterFeedIsLoading
      }
    }
  }

  let store: Store<TwitterFeedState, TwitterFeedAction>
  @ObservedObject var viewStore: ViewStore<TwitterFeedViewState, TwitterFeedAction>

  public init(store: Store<TwitterFeedState, TwitterFeedAction>) {
    self.store = store
    viewStore = ViewStore(store.scope(state: TwitterFeedViewState.init))
  }

  public var body: some View {
    TweetListView(store: viewStore.shouldDisplayPlaceholder ? .placeholder : self.store)
      .navigationBarTitleDisplayMode(.inline)
      .redacted(reason: viewStore.shouldDisplayPlaceholder ? .placeholder : [])
      .onAppear { viewStore.send(.onAppear) }
  }
}

// MARK: Preview

struct TwitterFeedView_Previews: PreviewProvider {
  static var previews: some View {
    TwitterFeedView(
      store: Store<TwitterFeedState, TwitterFeedAction>(
        initialState: TwitterFeedState(),
        reducer: twitterFeedReducer,
        environment: TwitterFeedEnvironment(
          service: .noop,
          mainQueue: .failing,
          uiApplicationClient: .noop
        )
      )
    )
  }
}

public extension Array where Element == Tweet {
  static let placeHolder: Self = [0, 1, 2, 3, 4].map {
    Tweet(
      id: String($0),
      text: String("Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed invidunt ut labore et dolore".dropLast($0)),
      createdAt: .init(timeIntervalSince1970: TimeInterval(1635521516)),
      user: .init(
        name: "Critical Maps",
        screenName: "@maps",
        profileImageUrl: ""
      )
    )
  }
}

extension Store where State == TwitterFeedState, Action == TwitterFeedAction {
  static let placeholder = Store(
    initialState: .init(contentState: .results(.placeHolder)),
    reducer: .empty,
    environment: ()
  )
}
