import Foundation
import SharedModels
import SwiftUI
import ComposableArchitecture
import UIApplicationClient
import Styleguide

public struct TwitterFeedView: View {
  let store: Store<TwitterFeedState, TwitterFeedAction>
  @ObservedObject var viewStore: ViewStore<TwitterFeedState, TwitterFeedAction>
  
  public init(store: Store<TwitterFeedState, TwitterFeedAction>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }
  
  public var body: some View {
    TweetListView(
      store: viewStore.twitterFeedIsLoading
      ? .placeholder
      : self.store
    )
    .redacted(reason: viewStore.twitterFeedIsLoading ? .placeholder : [])
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
  static let placeHolder: Self = [0,1,2,3,4].map {
    Tweet(
      id: String($0),
      text: String("Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore".dropLast($0)),
      createdAt: .init(timeIntervalSince1970: TimeInterval(1635521516 - $0)),
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