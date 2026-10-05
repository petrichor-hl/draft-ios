//
//  ObservationLab.swift
//  Draft
//

import SwiftUI

struct ObservationLab: View {
  @Environment(AppCoordinator.self) private var coordinator

  var body: some View {
    List {
      Button {
        coordinator.push(.observationComparison)
      } label: {
        LabRow(
          title: "1. Observable vs ObservableObject",
          subtitle: "Track từng property và track cả object; thử struct, mảng và Equatable"
        )
      }

      Button {
        coordinator.push(.observationBodyTracking)
      } label: {
        LabRow(
          title: "2. Dependency trong body",
          subtitle: "LibraryView truyền Book; chỉ BookView đọc title"
        )
      }

      Button {
        coordinator.push(.observationBindable)
      } label: {
        LabRow(
          title: "3. @Bindable",
          subtitle: "BookEditView với TextField và Toggle"
        )
      }
    }
    .navigationTitle("Observation Lab")
  }
}

private struct LabRow: View {
  let title: LocalizedStringKey
  let subtitle: LocalizedStringKey

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(title).font(.headline)
      Text(subtitle).font(.caption).foregroundStyle(.secondary)
    }
    .padding(.vertical, 4)
  }
}

#Preview {
  NavigationStack {
    ObservationLab()
      .environment(AppCoordinator())
  }
}
