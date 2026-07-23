//
//  ProfileScreen.swift
//  Draft
//
//  Màn hình Profile — nội dung độc lập, không biết gì về side menu.
//

import SwiftUI

struct ProfileScreen: View {
  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: "person.crop.circle.fill")
        .font(.system(size: 80))
        .foregroundStyle(.tint)
      Text("Lam Tran").font(.title.bold())
      Text("tl.hoanglam174@gmail.com").foregroundStyle(.secondary)
      Spacer()
    }
    .padding(.top, 40)
  }
}

#Preview {
  ProfileScreen()
}
