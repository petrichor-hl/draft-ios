//
//  ShareTextScreen.swift
//  Draft
//
//  TODO — Dùng ShareLink để chia sẻ chuỗi văn bản.
//  Thử nội dung nhiều dòng và tiếng Việt; kiểm tra nội dung nhận được khi Copy.
//  So sánh các app đích và action với bài chia sẻ URL.

import SwiftUI

struct ShareTextScreen: View {
    var body: some View {
        Text("Hello, World!")
            .navigationTitle("Share text")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ShareTextScreen()
    }
}
