//
//  BaselineScreen.swift
//  Draft
//
//  Cách Baseline: safeAreaInset + scrollDismissesKeyboard.
//  Thanh nhập bị "desync" (tách rời bàn phím) khi kéo interactive.
//

import SwiftUI

struct BaselineScreen: View {
  @State private var text = ""
  @FocusState private var isFocused: Bool

  var body: some View {
    ScrollView {
      LazyVStack(spacing: 12) {
        // 30 dòng giả để có cái mà cuộn
        ForEach(0..<30, id: \.self) { i in
          Text("Message \(i)")
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.gray.opacity(0.15), in: .rect(cornerRadius: 16))
            .frame(maxWidth: .infinity,
                   alignment: i.isMultiple(of: 2) ? .leading : .trailing)
            .padding(.horizontal)
        }
      }
      .padding(.vertical)
    }
    .scrollDismissesKeyboard(.interactively)    // Hành vi 2: kéo để ẩn phím
    .onTapGesture { isFocused = false }         // Hành vi 1: tap ra ngoài để ẩn phím
    .safeAreaInset(edge: .bottom) {
      HStack(spacing: 8) {
        TextField("Aa", text: $text, axis: .vertical)
          .focused($isFocused)
          .lineLimit(1...5)
          .padding(8)
          .background(.gray.opacity(0.15), in: .capsule)

        Button {
          text = ""
        } label: {
          Image(systemName: "arrow.up.circle.fill")
            .font(.title)
        }
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .background(.bar)
    }
    .navigationTitle("Baseline")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    BaselineScreen()
  }
}
