//
//  TrackingScreen.swift
//  Draft
//
//  Cách B — tự đọc chiều cao bàn phím rồi đẩy thanh nhập lên theo.
//  TODO: bạn sẽ điền phần này (Bước B1, B2...).
//

import SwiftUI

struct TrackingScreen: View {
  @State private var text = ""
  @FocusState private var isFocused: Bool
  
  @State private var keyboardHeight: CGFloat = 0
  @State private var bottomInset: CGFloat = 0
  
  var body: some View {
    VStack(spacing: 8) {
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
        .padding()
      }
      .onTapGesture { isFocused = false }
      
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
    .padding(.bottom, max(0, keyboardHeight - bottomInset))
    .ignoresSafeArea(.keyboard, edges: .bottom)
    .onAppear {
      bottomInset = (UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow })?
        .safeAreaInsets.bottom ?? 0
    }
    .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { notification in
      guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
      withAnimation(.easeOut(duration: 0.25)) {
        keyboardHeight = frame.height
      }
      // print("keyboardHeight = \(keyboardHeight)")
    }
    .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
      withAnimation(.easeOut(duration: 0.25)) {
        keyboardHeight = 0
      }
      // print("keyboardHeight = \(keyboardHeight)")
    }
    .navigationTitle("Tracking")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    TrackingScreen()
  }
}
