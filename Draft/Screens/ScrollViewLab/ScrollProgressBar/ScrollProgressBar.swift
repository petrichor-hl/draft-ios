import SwiftUI

// Các giá trị của ScrollGeometry dùng để tính tiến độ cuộn dọc (đơn vị: pt):
// - contentSize.height: Chiều cao toàn bộ nội dung bên trong scroll view,
//   kể cả phần nằm ngoài khung nhìn; chưa cộng contentInsets.
// - contentInsets.top: Khoảng chừa thêm phía trên khối nội dung do scroll view áp dụng.
// - contentInsets.bottom: Khoảng chừa thêm phía dưới khối nội dung do scroll view áp dụng.
// - containerSize.height: Chiều cao viewport đã trừ top và bottom contentInsets,
//   không phải chiều cao toàn bộ khung UIScrollView bên dưới.
//   Quãng đường có thể cuộn = contentSize.height - containerSize.height;
//   không cộng contentInsets lần nữa để tránh tính dư (ví dụ: cuối chỉ đạt 97%).

struct ScrollProgressBarLab: View {
  @Environment(AppCoordinator.self) private var coordinator

  var body: some View {
    List {
      if #available(iOS 18.0, *) {
        Button {
          coordinator.push(.scrollProgressBarModern)
        } label: {
          row(
            title: "1. iOS 18+",
            subtitle: "onScrollGeometryChange — ScrollView và List"
          )
        }
      }

      Button {
        coordinator.push(.scrollProgressBarLegacy)
      } label: {
        row(
          title: "2. iOS 17 và trước đó",
          subtitle: "GeometryReader + PreferenceKey — ScrollView"
        )
      }
    }
    .navigationTitle("Scroll Progress Bar Lab")
    .navigationBarTitleDisplayMode(.inline)
  }

  private func row(title: LocalizedStringKey, subtitle: LocalizedStringKey) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(title).font(.headline)
      Text(subtitle).font(.caption).foregroundStyle(.secondary)
    }
    .padding(.vertical, 4)
  }
}

#Preview {
  NavigationStack {
    ScrollProgressBarLab()
      .environment(AppCoordinator())
  }
}
