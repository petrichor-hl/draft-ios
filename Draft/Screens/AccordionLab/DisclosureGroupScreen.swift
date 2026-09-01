//
//  DisclosureGroupScreen.swift
//  Draft
//
//  Mục 1 của Accordion Lab — hàng Apple cho sẵn.
//
//  `DisclosureGroup` lo giùm chevron, góc xoay và animation. Ba dạng ở đây đi
//  từ ít quyền kiểm soát tới nhiều:
//
//      1a  DisclosureGroup("title") { ... }              tự giữ state
//      1b  DisclosureGroup("title", isExpanded: $x) { }  state ở NGOÀI
//      1c  DisclosureGroup { ... } label: { ... }        label tuỳ biến
//
//  Bản `isExpanded:` là bản lề của cả lab: nó chấp nhận state ở ngoài, nên
//  cụm single-open (mục 4) hoàn toàn làm được bằng đồ có sẵn. Tự dựng ở mục 2
//  là để đổi lấy phần NHÌN, không phải vì SwiftUI thiếu hành vi.
//

import SwiftUI

struct DisclosureGroupScreen: View {
  /// State của #2 nằm ở ĐÂY chứ không nằm trong DisclosureGroup — nhờ vậy cái
  /// `Button` bên dưới mới với tới được.
  @State private var isSecondExpanded = false

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        Text(
          """
          Bấm thẳng vào header thì DisclosureGroup tự gói animation. Đổi state \
          từ bên ngoài thì không ai gói giùm — đó là khác biệt đáng nhớ nhất ở màn này.
          """
        )
        .font(.footnote)
        .foregroundStyle(.secondary)

        // ── 1a · Dạng ngắn nhất: DisclosureGroup TỰ giữ state bên trong ─────
        //
        // Không có @State nào của mình. Đủ dùng khi không ai bên ngoài cần
        // biết nó đang mở hay đóng.
        VStack(alignment: .leading, spacing: 8) {
          SubTitle("1a · Tự giữ state")

          DisclosureGroup("Accordion Item #1") {
            Text(Self.sample)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
        }

        Divider()

        // ── 1b · State nằm NGOÀI, view chỉ đọc/ghi qua binding ──────────────
        VStack(alignment: .leading, spacing: 8) {
          SubTitle("1b · State ở ngoài — isExpanded:")

          DisclosureGroup("Accordion Item #2", isExpanded: $isSecondExpanded) {
            Text(Self.sample)
              .frame(maxWidth: .infinity, alignment: .leading)
              // Để tự trả lời: content được dựng NGAY TỪ ĐẦU hay tới lúc mở
              // mới dựng? Bấm mở rồi xem console. Câu trả lời quyết định có
              // dám nhét ảnh nặng / gọi mạng vào body accordion hay không.
              .onAppear { print("content #2 onAppear") }
          }

          Button("Đóng/mở #2 từ bên ngoài") {
            // Bỏ `withAnimation` đi rồi bấm lại: nó bật ra khô khốc. Bấm thẳng
            // vào header #2 thì vẫn mượt — vì lúc đó DisclosureGroup tự gói
            // animation trong hành động của CHÍNH NÓ.
            withAnimation {
              isSecondExpanded.toggle()
            }
          }
          .buttonStyle(.bordered)
        }

        Divider()

        // ── 1c · Label tuỳ biến — không chỉ nhận được String ────────────────
        //
        // Nhưng chevron vẫn nằm bên phải và vẫn là chevron: muốn đổi phải viết
        // `DisclosureGroupStyle`. Đó là lúc tự dựng bắt đầu rẻ hơn.
        VStack(alignment: .leading, spacing: 8) {
          SubTitle("1c · Label tuỳ biến")

          DisclosureGroup {
            Text(Self.sample)
              .frame(maxWidth: .infinity, alignment: .leading)
          } label: {
            HStack(spacing: 8) {
              Image(systemName: "questionmark.circle")
              Text("Label tuỳ biến")
              Spacer()
              Text(verbatim: "3")
                .font(.caption)
                .foregroundStyle(.secondary)
            }
          }
        }
      }
      .font(.callout)
      .padding(20)
    }
    .navigationTitle("1 · DisclosureGroup")
    .navigationBarTitleDisplayMode(.inline)
  }
}

// MARK: - Của riêng màn này

private extension DisclosureGroupScreen {
  static let sample = """
    This is the accordion body. It is shown by default, until the collapse \
    plugin adds the appropriate classes that we use to style each element.
    """

  func SubTitle(_ text: LocalizedStringKey) -> some View {
    Text(text)
      .font(.caption.weight(.semibold))
      .foregroundStyle(.secondary)
  }
}

#Preview {
  NavigationStack {
    DisclosureGroupScreen()
  }
}
