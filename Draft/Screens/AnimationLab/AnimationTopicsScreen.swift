//
//  AnimationTopicsScreen.swift
//  Draft
//
//  Danh mục 11 nhóm chủ đề của trang Animations trong tài liệu Apple.
//  Tách khỏi LearnAnimation cho menu chính khỏi dài.
//
//  https://developer.apple.com/documentation/swiftui/animations
//

import SwiftUI

struct AnimationTopicsScreen: View {
  @Environment(AppCoordinator.self) private var coordinator

  var body: some View {
    List {
      Section {
        ForEach(AnimationTopic.allCases) { topic in
          Button {
            coordinator.push(.animationTopic(topic))
          } label: {
            Text(topic.title)
              .font(.subheadline)
              .padding(.vertical, 2)
          }
        }
      } footer: {
        Text("developer.apple.com/documentation/swiftui/animations")
      }
    }
    .navigationTitle("Topics")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    AnimationTopicsScreen()
      .environment(AppCoordinator())
  }
}
