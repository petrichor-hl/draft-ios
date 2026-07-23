//
//  SettingsScreen.swift
//  Draft
//
//  Màn hình Settings — nội dung độc lập, không biết gì về side menu.
//

import SwiftUI

struct SettingsScreen: View {
  @State private var notifications = true
  @State private var darkMode = false

  var body: some View {
    Form {
      Toggle("Thông báo", isOn: $notifications)
      Toggle("Chế độ tối", isOn: $darkMode)
    }
  }
}

#Preview {
  SettingsScreen()
}
