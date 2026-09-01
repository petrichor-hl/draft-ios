//
//  CameraLabRow.swift
//  Draft
//
//  Một dòng menu dùng chung cho các màn hình trong Camera Lab.
//

import SwiftUI

struct CameraLabRow: View {
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
