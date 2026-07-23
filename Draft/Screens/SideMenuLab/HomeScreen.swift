//
//  HomeScreen.swift
//  Draft
//
//  Màn hình Home — nội dung độc lập, không biết gì về side menu.
//

import SwiftUI

struct HomeScreen: View {
  var body: some View {
    List {
      Section("Home / Push-style Side Menu") {
        Text("Kéo từ GIỮA màn hình sang phải → mở menu")
        Text("Kéo từ SÁT cạnh trái → back (pop)")
      }
    }
  }
}

#Preview {
  HomeScreen()
}
