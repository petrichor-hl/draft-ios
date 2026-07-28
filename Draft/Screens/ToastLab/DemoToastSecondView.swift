//
//  DemoToastSecondView.swift
//  Draft
//
//  Copied from SecondView in the MaverickToast prototype.
//

import SwiftUI

struct DemoToastSecondView: View {

  @Environment(\.dismiss) private var dismiss

  var body: some View {
    VStack {
      Text("Second View")
        .font(.title)

      Button("Go back") {
        dismiss()
      }
    }
    .padding()
    .navigationTitle("Second View")
  }
}

#Preview {
  NavigationStack {
    DemoToastSecondView()
  }
}
