//
//  MenuWithLabeledContent.swift
//  Draft
//
//  Cùng một dòng LabeledContent("Subscription Plan", value: "Pro") làm label của
//  submenu, ba phiên bản iOS vẽ ra ba kiểu khác nhau:
//    iOS 18.6 (22G86)  — chỉ "Subscription Plan", mất "Pro", chevron bên trái
//    iOS 26.5 (23F77)  — chỉ "Subscription Plan", mất "Pro", chevron bên phải
//    iOS 27.0 (24A434) — "Subscription Plan" + dòng nhỏ "Pro", chevron bên phải
//
//  B là bản đối chứng: bỏ LabeledContent, thay bằng hai Text thường.
//

import SwiftUI

struct MenuWithLabeledContent: View {
  var body: some View {
    List {
      // A — LabeledContent làm label của submenu
      Section {
        Menu("Account", systemImage: "person.circle") {
          Menu {
            Button("Free") {}
            Button("Pro") {}
          } label: {
            LabeledContent("Subscription Plan", value: "Pro")
          }

          Divider()

          Button("Settings", systemImage: "gear") {}
          Button("Sign Out", systemImage: "rectangle.portrait.and.arrow.right") {}
        }
      } header: {
        Text("A — LabeledContent làm label của submenu")
      } footer: {
        Text("Chỉ iOS 27 mới vẽ phần value thành dòng nhỏ. iOS 18 và 26 nhận đúng đoạn code này nhưng vứt luôn chữ \"Pro\", không báo lỗi gì.")
      }

      // B — bỏ LabeledContent, thay bằng hai Text thường
      Section {
        Menu("Account", systemImage: "person.circle") {
          Menu {
            Button("Free") {}
            Button("Pro") {}
          } label: {
            Text("Subscription Plan")
            Text("Pro")
          }

          Divider()

          Button("Settings", systemImage: "gear") {}
          Button("Sign Out", systemImage: "rectangle.portrait.and.arrow.right") {}
        }
      } header: {
        Text("B — đối chứng: hai Text thường")
      } footer: {
        Text("Không có LabeledContent nào ở đây, nhưng trên **iOS 27** mở ra y hệt A.")
      }

      Section {
        LabeledContent("iOS 18.6", value: "mất \"Pro\"")
        LabeledContent("iOS 26.5", value: "mất \"Pro\"")
        LabeledContent("iOS 27.0", value: "có \"Pro\"")
      } header: {
        Text("Đã đo tay trên simulator")
      } footer: {
        Text("Chevron cũng đổi chỗ: iOS 18 để bên trái, từ 26 chuyển sang phải. Riêng dòng phụ thì phải tới 27 mới có.")
      }

      Section("Đang chạy trên") {
        LabeledContent("iOS", value: ProcessInfo.processInfo.operatingSystemVersionString)
      }
    }
    .navigationTitle("Subtitle trong Menu")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    MenuWithLabeledContent()
  }
}
