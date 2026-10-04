//
//  SafeAreaInsetDynamicHeightScreen.swift
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
// isExpanded: false → 70pt, true → 200pt. Chạm thanh để toggle trong
// withAnimation. Chiều cao thay đổi thì safe area dành cho List cũng đổi.
// spacing: 0 bỏ khoảng cách thêm; padding nằm trong nội dung của inset.
//
// LƯU Ý — tránh đặt component thay đổi chiều cao bằng animation trong
// safeAreaInset khi cần giữ bố cục và vị trí cuộn của List ổn định.
// Có thể gây nhảy hàng hoặc chuyển động không khớp ("break UI"); thử ở
// cuối danh sách để quan sát trên phiên bản iOS đang dùng.

import SwiftUI

struct SafeAreaInsetDynamicHeightScreen: View {
    @State private var isExpanded = false

    var body: some View {
        List {
            Text("Nhấn vào RoundedRectangle để expand hoặc collapse nó\nQuan sát lỗi UI khi RoundedRectangle từ 200pt thu nhỏ về 70pt")
            
            ForEach(0..<15) { _ in
                episodeCell
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(Color.pink.gradient.opacity(0.8))
                .frame(maxWidth: .infinity)
                .frame(height: isExpanded ? 200 : 70)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
                .onTapGesture {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }
        }
        .navigationTitle("Dynamic height")
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
        SafeAreaInsetDynamicHeightScreen()
    }
}
