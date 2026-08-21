//
//  HapticLabRow.swift
//  Draft
//
//  Một dòng menu dùng chung cho các màn hình trong Haptics Lab.
//

import SwiftUI

struct HapticLabRow: View {
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
