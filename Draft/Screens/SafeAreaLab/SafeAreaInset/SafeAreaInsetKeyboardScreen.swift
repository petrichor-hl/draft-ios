//
//  SafeAreaInsetKeyboardScreen.swift
//  Draft
//
//  Youtube: https://www.youtube.com/watch?v=cpT02OtOasE
//
// Đặt thanh hồng cố định ở cạnh dưới của vùng an toàn.
// safeAreaInset dành chỗ theo chiều cao của nội dung trong closure
// và điều chỉnh safe area mà List nhận được. Nhờ đó, khi cuộn tới
// cuối, hàng cuối có thể nằm phía trên thanh và vẫn đọc/chạm được.
// Thanh nằm ngoài nội dung cuộn nên không cuộn theo các episode.
//
// Chạm TextField để hiện bàn phím, rồi quan sát vị trí thanh hồng
// và vùng cuộn của List. Thanh giữ chiều cao 70pt.
// Nút Hide keyboard hoặc phím Done đưa focus về false để ẩn bàn phím.

import SwiftUI

struct SafeAreaInsetKeyboardScreen: View {
    @State private var text = ""
    @FocusState private var isTextFocused: Bool

    var body: some View {
        List {
            Text("Nhấn Hide keyboard và Quan sát lỗi UI khi keyboard trượt xuống để ẩn")
            
            TextField("Nhập để mở bàn phím", text: $text)
                .focused($isTextFocused)
                .submitLabel(.done)
                .onSubmit { isTextFocused = false }

            ForEach(0..<15) { _ in
                episodeCell
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(Color.pink.gradient.opacity(0.8))
                .frame(maxWidth: .infinity)
                .frame(height: 70)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Hide keyboard") {
                    isTextFocused = false
                }
            }
        }
        .navigationTitle("Keyboard")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var episodeCell: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .frame(width: 80, height: 80)
                .foregroundStyle(Color.indigo.gradient.opacity(0.5))
            
            VStack(alignment: .leading) {
                Text("Episode Title")
                    .font(.headline)
                
                Text("Here is the short description for the latest episode.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SafeAreaInsetKeyboardScreen()
            .environment(AppCoordinator())
    }
}
