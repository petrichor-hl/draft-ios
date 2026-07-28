//
//  SnackBarLab.swift
//  Draft
//

import SwiftUI

struct SnackBarLab: View {
  @State private var undoCount = 0
  @State private var isSheetPresented = false
  
  var body: some View {
    List {
      Section("Cơ bản") {
        Button("Có action button") {
          SnackBarManager.shared.show(
            action: SnackBarAction(label: "Hoàn tác") { undoCount += 1 }
          ) {
            HStack(spacing: 12) {
              Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.green)
              Text("Đã xoá nguyên liệu")
            }
          }
        }
        
        Button("Không có action button") {
          SnackBarManager.shared.show {
            Text("Đã lưu bữa ăn vào nhật ký")
          }
        }
        
        Button("Content dài (2 dòng)") {
          SnackBarManager.shared.show(action: SnackBarAction(label: "Thử lại") {}) {
            Text("Không thể đồng bộ dữ liệu, vui lòng kiểm tra kết nối mạng của bạn")
          }
        }
      }
      
      Section("Thay thế") {
        Button("Bắn 3 cái liên tiếp (cách nhau 1s)") {
          Task { @MainActor in
            for index in 1...3 {
              SnackBarManager.shared.show(action: SnackBarAction(label: "Hoàn tác") {}) {
                Text("SnackBar #\(index)")
              }
              try? await Task.sleep(for: .seconds(1))
            }
          }
        }
        
        Button("Bắn 3 cái cùng lúc") {
          for index in 1...3 {
            SnackBarManager.shared.show {
              Text("SnackBar #\(index)")
            }
          }
        }
      }
      
      Section("Nổi trên sheet") {
        Button("Mở sheet rồi show snackbar") {
          isSheetPresented = true
        }
      }
      
      Section("Trạng thái") {
        LabeledContent("Số lần bấm Hoàn tác", value: "\(undoCount)")
        Text("Vuốt/bấm vào List trong lúc snackbar hiển thị để kiểm tra passthrough.")
          .font(.footnote)
          .foregroundStyle(Color.secondary)
      }
    }
    .navigationTitle("SnackBar Lab")
    .sheet(isPresented: $isSheetPresented) {
      sheetContent
    }
  }
  
  // MARK: - Views
  
  private var sheetContent: some View {
    VStack(spacing: 20) {
      Text("SnackBar phải nổi trên sheet này")
        .font(.headline)
      
      Button("Show snackbar") {
        SnackBarManager.shared.show(
          action: SnackBarAction(label: "Hoàn tác") { undoCount += 1 }
        ) {
          HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
              .foregroundStyle(Color.green)
            Text("Đã xoá nguyên liệu")
          }
        }
      }
      .buttonStyle(.borderedProminent)
      
      Button("Đóng sheet") {
        isSheetPresented = false
      }
    }
    .padding(24)
    .presentationDetents([.medium])
  }
}
