import Foundation
import SharedModels
import Styleguide
import SwiftUI

/// A view that renders a tweet
public struct TweetView: View {
  @Environment(\.accessibilityReduceMotion) var reduceMotion
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize: DynamicTypeSize
  let tweet: Tweet
  
  public init(tweet: Tweet) {
    self.tweet = tweet
  }
  
  public var body: some View {
    ZStack {
      HStack(alignment: .top, spacing: .grid(4)) {
        AsyncImage(
          url: tweet.user.profileImage,
          transaction: Transaction(animation: reduceMotion ? nil : .easeInOut)
        ) { phase in
          switch phase {
          case .empty:
            Color(.textSilent).opacity(0.6)
          case let .success(image):
            image
              .resizable()
              .transition(.opacity)
          case .failure:
            Color(.textSilent).opacity(0.6)
          @unknown default:
            EmptyView()
          }
        }
        .frame(width: 44, height: 44)
        .background(Color.gray)
        .clipShape(Circle())
        
        VStack(alignment: .leading, spacing: .grid(2)) {
          if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading) {
              twitterUserName
              twitterScreenName
              tweetPostDatetime
            }
          } else {
            HStack {
              twitterUserName
              twitterScreenName
              Spacer()
              tweetPostDatetime
            }
          }
          Text(tweet.makeAttributedTweet)
            .multilineTextAlignment(.leading)
            .font(.bodyOne)
            .foregroundColor(Color(.textSecondary))
        }
      }
    }
    .accessibilityElement(children: .combine)
    .padding(.vertical, .grid(2))
  }
  
  var twitterUserName: some View {
    Text(tweet.user.name)
      .lineLimit(1)
      .font(.titleTwo)
      .foregroundColor(Color(.textPrimary))
  }
  
  var twitterScreenName: some View {
    Text(tweet.user.screenName)
      .lineLimit(1)
      .font(.bodyTwo)
      .foregroundColor(Color(.textSilent))
  }
  
  var tweetPostDatetime: some View {
    Text(tweet.formattedCreationDate()!)
      .font(.meta)
      .foregroundColor(Color(.textPrimary))
  }
}

// MARK: Preview

struct TweetView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      TweetView(tweet: [Tweet].placeHolder[0])
      
      TweetView(tweet: [Tweet].placeHolder[0])
        .redacted(reason: .placeholder)
    }
  }
}

public extension Tweet {
  var makeAttributedTweet: NSAttributedString {
    NSAttributedString.highlightMentionsAndTags(in: text)
  }
  
  func formattedCreationDate(
    currentDate: () -> Date = Date.init,
    calendar: () -> Calendar = { .current }
  ) -> String? {
    let components = calendar().dateComponents(
      [.hour, .day, .month],
      from: createdAt,
      to: currentDate()
    )
    
    if let days = components.day, days == 0, let months = components.month, months == 0 {
      let diffComponents = calendar().dateComponents([.hour, .minute], from: createdAt, to: currentDate())
      return DateComponentsFormatter.tweetDateFormatter()
        .string(from: diffComponents.dateComponentFromBiggestComponent)
    } else {
      return DateFormatter.mediumDateFormatter.string(from: createdAt)
    }
  }
}

extension DateComponents {
  var dateComponentFromBiggestComponent: DateComponents {
    if let day = day, day != 0 {
      return DateComponents(calendar: calendar, day: day)
    } else if let hour = hour, hour != 0 {
      return DateComponents(calendar: calendar, hour: hour)
    } else {
      return DateComponents(calendar: calendar, minute: minute)
    }
  }
}
