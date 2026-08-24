//
//  FlowRowScreen.swift
//  Draft
//
//  FlowRow của Jetpack Compose, dựng lại bằng `Layout` của SwiftUI.
//
//  Xếp các con thành một hàng ngang, hết chỗ thì XUỐNG DÒNG. Nghe như
//  `HStack` biết wrap, nhưng `HStack` không wrap được: nó chỉ có một hàng và
//  khi thiếu chỗ thì đi BÓP con lại chứ không xuống dòng.
//
//  ⚠️ SwiftUI KHÔNG có sẵn thứ này, kể cả ở iOS 26.5. Đã kiểm bằng cách grep
//     `SwiftUI.swiftinterface` trong SDK: 0 kết quả cho "flow", và hai
//     `Layout` dựng sẵn duy nhất là `GridLayout` với
//     `AligningContentProviderLayout`. `Grid` thì khác hẳn — nó chia CỘT cố
//     định, còn flow là số phần tử mỗi hàng thay đổi theo bề rộng.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  1. HAI HÀM CỦA `Layout`, VÀ VÌ SAO CHÚNG PHẢI KHỚP NHAU
//  ═══════════════════════════════════════════════════════════════════════════
//
//      sizeThatFits   cha hỏi "được đề nghị ngần này, mày cần bao nhiêu?"
//      placeSubviews  cha bảo "đây là chỗ mày được cấp, đặt con vào đi"
//
//  Hai hàm chạy ở hai thời điểm khác nhau, và cha KHÔNG bắt buộc cấp đúng cái
//  bạn đã xin. Nên `placeSubviews` phải tính lại việc chia hàng từ
//  `bounds.width`, không được dùng lại kết quả đã tính trong `sizeThatFits`.
//  Dùng lại là hai hàm nói hai chuyện: chữ tràn ra ngoài khung, hoặc khung
//  thừa một khoảng trắng ở đáy.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  2. ĐO CON BẰNG `.unspecified`, KHÔNG BẰNG ĐỀ NGHỊ CỦA CHA
//  ═══════════════════════════════════════════════════════════════════════════
//
//  Cái bẫy lớn nhất của flow layout. Muốn biết "chip này rộng bao nhiêu" thì
//  phải hỏi:
//
//      subview.sizeThatFits(.unspecified)      // ✓ bề rộng TỰ NHIÊN
//      subview.sizeThatFits(proposal)          // ✗ bề rộng của CẢ KHUNG
//
//  Hỏi theo `proposal` là mỗi chip tưởng nó được cấp trọn bề ngang màn hình.
//  `Text` không nở ra nên có vẻ vẫn đúng — cho tới khi bạn nhét vào một chip
//  có `.frame(maxWidth: .infinity)` hay một `Text` dài phải xuống dòng, lúc đó
//  mọi thứ vỡ cùng lúc và rất khó lần.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  3. CÁI GÌ CACHE ĐƯỢC, CÁI GÌ KHÔNG
//  ═══════════════════════════════════════════════════════════════════════════
//
//  `Layout` cho một `Cache` để khỏi đo lại mỗi lần. Nhưng ranh giới rất sắc:
//
//      kích thước từng con   KHÔNG phụ thuộc bề rộng khung  → cache được
//      cách chia hàng        PHỤ THUỘC bề rộng khung        → KHÔNG cache
//
//  Cache nhầm vế thứ hai thì xoay ngang màn hình hoặc kéo slider bên dưới sẽ
//  cho bố cục của bề rộng CŨ, và nó chỉ sai lúc bề rộng đổi — nghĩa là không
//  bao giờ lộ ra trong preview tĩnh.
//
//  ═══════════════════════════════════════════════════════════════════════════
//  4. MỘT TÍNH CHẤT DỄ TƯỞNG LÀ MAY MẮN
//  ═══════════════════════════════════════════════════════════════════════════
//
//  Cách xếp tham lam (nhét được thì nhét, không thì xuống dòng) có tính chất:
//  chia hàng ở bề rộng W rồi lấy M = bề rộng hàng rộng nhất, thì chia lại ở M
//  cho ra ĐÚNG các hàng cũ.
//
//  Vì hàng 1 dừng ở phần tử k do `width(1...k+1) > W`, mà `M ≤ W` nên
//  `width(1...k+1) > M`, hàng 1 vẫn dừng đúng chỗ đó. Quy nạp cho các hàng
//  sau. Nhờ vậy `sizeThatFits` trả về bề rộng nào trong khoảng `[M, W]` cũng
//  không làm bố cục nhảy — một chỗ hiếm hoi trong layout mà bạn được an toàn
//  miễn phí.
//
//  Ở đây vẫn trả về đúng bề rộng ĐƯỢC ĐỀ NGHỊ chứ không phải `M`, để khớp ngữ
//  nghĩa FlowRow bên Compose: nó chiếm trọn constraint và `horizontalArrangement`
//  mới có chỗ mà căn. Trả về `M` thì khung co sát nội dung và `alignment` bên
//  dưới thành vô nghĩa.
//

import SwiftUI

// MARK: - Layout

/// Bản SwiftUI của `FlowRow` (Compose). Ánh xạ tham số:
///
///     Compose                          ở đây
///     ─────────────────────────────    ────────────────────
///     horizontalArrangement.spacedBy   horizontalSpacing
///     verticalArrangement.spacedBy     verticalSpacing
///     horizontalArrangement (căn)      alignment
///     itemVerticalAlignment            rowAlignment
///     maxItemsInEachRow                maxItemsInEachRow
struct FlowRow: Layout {
  var horizontalSpacing: CGFloat = 8
  var verticalSpacing: CGFloat = 8

  /// Căn các hàng theo chiều ngang trong khung. Chỉ thấy được khi khung rộng
  /// hơn hàng — tức là gần như luôn luôn, trừ hàng dài nhất.
  var alignment: HorizontalAlignment = .leading

  /// Căn các con theo chiều dọc TRONG một hàng, khi chúng cao thấp khác nhau.
  var rowAlignment: VerticalAlignment = .center

  /// Trần số phần tử mỗi hàng, kể cả khi còn thừa chỗ. `nil` là không giới hạn.
  var maxItemsInEachRow: Int?

  /// Chỉ chứa thứ KHÔNG phụ thuộc bề rộng khung — xem khối 3 đầu file.
  struct Cache {
    var sizes: [CGSize]
  }

  func makeCache(subviews: Subviews) -> Cache {
    Cache(sizes: Self.measure(subviews))
  }

  func updateCache(_ cache: inout Cache, subviews: Subviews) {
    cache.sizes = Self.measure(subviews)
  }

  func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Cache
  ) -> CGSize {
    // `nil` nghĩa là "muốn bao nhiêu cũng được", không phải 0 — coi như vô hạn
    // thì flow gom hết vào một hàng, đúng nghĩa "bề rộng lý tưởng".
    let available = proposal.width ?? .infinity
    let rows = rows(fitting: available, sizes: cache.sizes)

    let height = rows.map(\.height).reduce(0, +)
      + verticalSpacing * CGFloat(max(rows.count - 1, 0))

    // Khung vô hạn thì không thể trả về vô hạn — lấy bề rộng thật của nội dung.
    let width = available.isFinite
      ? available
      : (rows.map(\.width).max() ?? 0)

    return CGSize(width: width, height: height)
  }

  func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Cache
  ) {
    // Tính LẠI từ `bounds.width`, không tin con số đã tính ở `sizeThatFits` —
    // xem khối 1 đầu file.
    let rows = rows(fitting: bounds.width, sizes: cache.sizes)

    var y = bounds.minY
    for row in rows {
      let leftover = bounds.width - row.width
      var x = bounds.minX + leftover * alignmentFactor

      for index in row.indices {
        let size = cache.sizes[index]
        subviews[index].place(
          at: CGPoint(x: x, y: y + verticalOffset(for: size.height, in: row.height)),
          anchor: .topLeading,
          // Đề nghị ĐÚNG bằng cỡ đã đo. Truyền `.unspecified` ở đây thì con
          // được quyền tự chọn lại cỡ, và cỡ đó có thể khác cỡ vừa dùng để
          // chia hàng — bố cục lệch một cách rất khó thấy.
          proposal: ProposedViewSize(size)
        )
        x += size.width + horizontalSpacing
      }

      y += row.height + verticalSpacing
    }
  }

  // MARK: Của mình

  /// Một hàng đã chốt: chứa những con nào, rộng và cao bao nhiêu.
  private struct Row {
    var indices: [Int] = []
    var width: CGFloat = 0
    /// Cao bằng con cao nhất trong hàng.
    var height: CGFloat = 0
  }

  private static func measure(_ subviews: Subviews) -> [CGSize] {
    // `.unspecified` chứ không phải đề nghị của cha — xem khối 2 đầu file.
    subviews.map { $0.sizeThatFits(.unspecified) }
  }

  /// Xếp tham lam: nhét vào hàng hiện tại nếu còn vừa, không thì mở hàng mới.
  private func rows(fitting available: CGFloat, sizes: [CGSize]) -> [Row] {
    var rows: [Row] = []
    var current = Row()

    for (index, size) in sizes.enumerated() {
      let spacing = current.indices.isEmpty ? 0 : horizontalSpacing
      let widthIfAdded = current.width + spacing + size.width

      let hitItemLimit = maxItemsInEachRow.map { current.indices.count >= $0 } ?? false
      // `!current.indices.isEmpty` là điều kiện SỐNG CÒN: một con rộng hơn cả
      // khung vẫn phải được đặt vào một hàng, nếu không vòng lặp đẩy nó xuống
      // hàng mới mãi mà nó không bao giờ vừa.
      let hitWidthLimit = widthIfAdded > available && !current.indices.isEmpty

      if hitItemLimit || hitWidthLimit {
        rows.append(current)
        current = Row()
      }

      let gap = current.indices.isEmpty ? 0 : horizontalSpacing
      current.indices.append(index)
      current.width += gap + size.width
      current.height = max(current.height, size.height)
    }

    if !current.indices.isEmpty { rows.append(current) }
    return rows
  }

  private var alignmentFactor: CGFloat {
    switch alignment {
    case .center: return 0.5
    case .trailing: return 1
    default: return 0
    }
  }

  private func verticalOffset(for height: CGFloat, in rowHeight: CGFloat) -> CGFloat {
    switch rowAlignment {
    case .center: return (rowHeight - height) / 2
    case .bottom: return rowHeight - height
    default: return 0
    }
  }
}

// MARK: - Screen

struct FlowRowScreen: View {
  /// Bề rộng khung, chỉnh được để thấy các chip tự chia lại hàng.
  @State private var width: CGFloat = 340
  @State private var alignment: RowAlignment = .leading

  private enum RowAlignment: String, CaseIterable, Identifiable {
    case leading, center, trailing

    var id: String { rawValue }

    var horizontal: HorizontalAlignment {
      switch self {
      case .leading: return .leading
      case .center: return .center
      case .trailing: return .trailing
      }
    }
  }

  private let filters = [
    "Price: High to Low",
    "Avg rating: 4+",
    "Free breakfast",
    "Free cancellation",
    "£50 pn"
  ]

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        Text(
          """
          HStack không xuống dòng được — thiếu chỗ thì nó bóp con lại. FlowRow \
          hết chỗ thì mở hàng mới, nên số phần tử mỗi hàng đổi theo bề rộng.
          """
        )
        .font(.footnote)
        .foregroundStyle(.secondary)

        FlowRow(alignment: alignment.horizontal) {
          ForEach(filters, id: \.self) { filter in
            Chip(title: filter)
          }
        }
        .frame(width: width, alignment: .leading)
        .padding(.vertical, 12)
        .background(Color(uiColor: .secondarySystemBackground))

        VStack(alignment: .leading, spacing: 8) {
          // `Text(verbatim:)` chứ không nội suy: nội suy Int bị format theo
          // locale, 340 thành "340" ở en nhưng "340" / "3 40" tuỳ nơi khác.
          Text(verbatim: "Bề rộng khung: \(Int(width))pt")
            .font(.subheadline)
          Slider(value: $width, in: 120...360)
        }

        Picker("Căn hàng", selection: $alignment) {
          ForEach(RowAlignment.allCases) { option in
            Text(option.rawValue.capitalized).tag(option)
          }
        }
        .pickerStyle(.segmented)

        Text(
          """
          Kéo slider xuống hẹp để thấy chỗ đáng nhìn nhất: chip cuối cùng rơi \
          xuống hàng mới, và CHIỀU CAO của cả khối đổi theo. Chiều cao đó là \
          thứ sizeThatFits phải trả lời đúng — sai là khối dưới nó bị chèn.
          """
        )
        .font(.footnote)
        .foregroundStyle(.secondary)
      }
      .padding(20)
    }
    .navigationTitle("FlowRow")
    .navigationBarTitleDisplayMode(.inline)
  }
}

// MARK: - Chip

private struct Chip: View {
  let title: String

  var body: some View {
    Text(title)
      .font(.system(size: 17))
      .foregroundStyle(.primary)
      .padding(.horizontal, 16)
      .padding(.vertical, 10)
      .background(Color(uiColor: .secondarySystemFill), in: .capsule)
      .overlay {
        Capsule().strokeBorder(Color(uiColor: .separator), lineWidth: 1)
      }
  }
}

#Preview {
  NavigationStack {
    FlowRowScreen()
  }
}
