import SwiftUI

struct ScrollProgressBarLab: View {
  @Environment(AppCoordinator.self) private var coordinator

  var body: some View {
    List {
      if #available(iOS 18.0, *) {
        Button {
          coordinator.push(.scrollProgressBarModern)
        } label: {
          row(
            title: "1. iOS 18+",
            subtitle: "onScrollGeometryChange — ScrollView và List"
          )
        }
      }

      Button {
        coordinator.push(.scrollProgressBarLegacy)
      } label: {
        row(
          title: "2. iOS 17 và trước đó",
          subtitle: "GeometryReader + PreferenceKey — ScrollView"
        )
      }
    }
    .navigationTitle("Scroll Progress Bar Lab")
    .navigationBarTitleDisplayMode(.inline)
  }

  private func row(title: LocalizedStringKey, subtitle: LocalizedStringKey) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(title).font(.headline)
      Text(subtitle).font(.caption).foregroundStyle(.secondary)
    }
    .padding(.vertical, 4)
  }
}

#Preview {
  NavigationStack {
    ScrollProgressBarLab()
      .environment(AppCoordinator())
  }
}
