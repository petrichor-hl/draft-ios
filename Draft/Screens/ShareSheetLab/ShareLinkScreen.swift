//
//  ShareLinkScreen.swift
//  Draft
//
//  TODO — Dùng ShareLink để chia sẻ một URL hợp lệ.
//  Thêm SharePreview với tiêu đề và thumbnail; phân biệt preview với payload.
//  Quan sát header, app đích và action do hệ thống cung cấp.
//  Kiểm tra mở, đóng và mở lại share sheet trên iPhone và iPad.

import SwiftUI

struct ShareLinkScreen: View {
    var body: some View {
        Text("Hello, World!")
            .navigationTitle("Share a link")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ShareLinkScreen()
    }
}
