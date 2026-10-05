//
//  ObservationBodyTrackingScreen.swift
//  Draft
//
//  https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app
//  Dependency được tạo khi đọc observable property trong execution scope của body.
//  Đọc title trong Button action không tạo dependency cho LibraryView.body.
//

import SwiftUI
import Observation

struct ObservationBodyTrackingScreen: View {
  var body: some View {
    LibraryView()
      .navigationTitle("Dependency trong body")
      .navigationBarTitleDisplayMode(.inline)
  }
}

@Observable
private final class Book: Identifiable {
  let id = UUID()
  var title: String
  var isAvailable = true

  init(title: String) {
    self.title = title
  }
}

// Object thường, không @Observable/@Published. Tăng counter không invalidate view.
// @State chỉ giữ identity của probe cho vòng đời mỗi view, không gán lại trong body.
private final class BodyProbe {
  private var count = 0

  func record(_ name: String) -> Int {
    count += 1
    print("\(name).body chạy: \(count) lần")
    return count
  }
}

private struct LibraryView: View {
  @State private var books = (1...3).map { Book(title: "Book \($0)") }
  @State private var probe = BodyProbe()

  var body: some View {
    let _ = Self._printChanges()
    let evaluations = probe.record("LibraryView")

    List {
      Section("Cách kiểm chứng") {
        Text("Bấm đổi title của một sách. Kỳ vọng: chỉ BookView tương ứng tăng counter và đổi màu; LibraryView và các sách khác giữ nguyên.")
        Text("LibraryView chỉ đọc mảng books và truyền object xuống. BookView đọc book.title trong body nên tạo dependency với title.")
        Text("Counter đo số lần body được đánh giá, không phải số lần vẽ pixel. SwiftUI có thể đánh giá body thêm khi điều hướng hoặc môi trường thay đổi. So sánh trước/sau mỗi lần bấm khi màn hình đã ổn định.")
          .font(.footnote)
          .foregroundStyle(.secondary)
        Link(
          "Apple: Managing model data in your app",
          destination: URL(string: "https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app")!
        )
      }

      Section("View cha") {
        VStack(alignment: .leading, spacing: 4) {
          Text("LibraryView").font(.headline)
          Text("body chạy: \(evaluations) lần")
            .font(.subheadline.monospacedDigit())
          Text("Không đọc book.title trong body")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .accessibilityIdentifier("observation.libraryProbe")
      }

      Section("Thao tác từ LibraryView") {
        ForEach(books.indices, id: \.self) { index in
          // Label chỉ dùng index. Mọi lần đọc/ghi title nằm trong action,
          // chạy khi bấm nút, sau khi body đã được đánh giá xong.
          Button("Đổi title sách \(index + 1)") {
            let originalTitle = "Book \(index + 1)"
            let book = books[index]
            book.title = book.title == originalTitle
              ? "\(originalTitle) — đã đổi"
              : originalTitle
          }
          .accessibilityIdentifier("observation.changeTitle.\(index)")
        }

        Button("Đổi isAvailable sách 1 (không view nào đọc)") {
          books[0].isAvailable.toggle()
          print("Book 1.isAvailable: \(books[0].isAvailable)")
        }
        .accessibilityIdentifier("observation.changeAvailability")
      }

      Section("Các BookView — đọc title") {
        ForEach(books) { book in
          BookView(book: book)
            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
        }
      }
    }
  }
}

private struct BookView: View {
  var book: Book
  @State private var probe = BodyProbe()

  var body: some View {
    let _ = Self._printChanges()
    let evaluations = probe.record("BookView[\(book.id)]")
    // Màu thay đổi theo mỗi lần body chạy, không cần mutate SwiftUI state.
    let background = Color(
      hue: (Double(evaluations) * 0.17).truncatingRemainder(dividingBy: 1),
      saturation: 0.35,
      brightness: 0.95
    )

    VStack(alignment: .leading, spacing: 6) {
      Text(book.title)
        .font(.headline)
      Text("BookView.body chạy: \(evaluations) lần")
        .font(.caption.monospacedDigit())
    }
    .foregroundStyle(.black)
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(12)
    .background(background, in: RoundedRectangle(cornerRadius: 12))
  }
}

#Preview {
  NavigationStack {
    ObservationBodyTrackingScreen()
  }
}
