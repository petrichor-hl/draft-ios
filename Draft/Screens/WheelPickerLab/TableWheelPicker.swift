//
//  TableWheelPicker.swift
//  Draft
//
//  Bánh xe một cột, dựng trên UITableView.
//
//  UITableView kế thừa UIScrollView, và UITableViewDelegate kế thừa
//  UIScrollViewDelegate. Nên nó cho vật lý cuộn thật (momentum, giảm tốc) từ lớp
//  cha, và tái dùng cell từ lớp con.
//

import SwiftUI
import UIKit

// MARK: - Metrics

/// Số đo của RIÊNG bản table.
///
/// Cố ý không dùng chung với bản collection: hai bản khác nhau ở chỗ chiều cao
/// hàng có thay đổi hay không, mà đó lại chính là thứ `metrics` mô tả. Gộp lại
/// thì phải đọc cả hai mới hiểu được một.
///
/// Ở đây `rowHeight` mang MỘT nghĩa duy nhất: hàng nào cũng chiếm đúng chừng đó,
/// cả khi cuộn lẫn khi vẽ. Chỉ CHỮ co lại, chỗ thì không.
struct TableWheelMetrics {
  var rowHeight: CGFloat = 60
  var visibleRows: Int = 5
  var fontSize: CGFloat = 40

  /// Tỉ lệ co của chữ theo VÒNG tính từ tâm: [tâm, kề, xa].
  /// Mặc định tương đương một thang 44 / 40 / 32pt.
  var scaleRamp: [CGFloat] = [1, 40.0 / 44.0, 32.0 / 44.0]

  /// Độ mờ theo vòng, cùng quy ước.
  var alphaRamp: [CGFloat] = [1, 0.4, 0.2]

  static let `default` = TableWheelMetrics()

  /// Hàng nào cũng cao bằng nhau nên chiều cao khung là phép nhân thẳng.
  var height: CGFloat { CGFloat(visibleRows) * rowHeight }

  /// Nội suy tuyến tính trên một thang rời rạc theo vòng.
  ///
  /// `distance` là số thực vì lúc cuộn nó ở giữa hai vòng — tra bảng bằng
  /// `Int(distance)` sẽ nhảy bậc.
  func ramp(_ values: [CGFloat], at distance: CGFloat) -> CGFloat {
    guard let last = values.last else { return 1 }
    let clamped = min(max(distance, 0), CGFloat(values.count - 1))
    let lower = Int(clamped)
    guard lower + 1 < values.count else { return last }
    let t = clamped - CGFloat(lower)
    return values[lower] + (values[lower + 1] - values[lower]) * t
  }
}

// MARK: - Wheel

/// Đẩy một chỉ số trong mảng nhãn đã render sẵn. Không biết gì về ml, cm, kg hay
/// năm — ai sở hữu đơn vị thì người đó làm số học.
struct TableWheelPicker: View {
  var values: [String]
  @Binding var selectedIndex: Int
  /// Bỏ trống cho cột TRẦN (năm sinh chẳng hạn). Plinth vẫn vẽ, vì nó là
  /// vạch chỉ chỗ đang chọn chứ không phải nền cho chữ đơn vị.
  var unitLabel: String = ""
  var metrics: TableWheelMetrics = .default

  var body: some View {
    ZStack {
      WheelPlinth(unitLabel: unitLabel, height: metrics.rowHeight)

      TableWheelColumn(
        values: values,
        selectedIndex: $selectedIndex,
        metrics: metrics
      )
    }
    .frame(height: metrics.height)
  }
}

// MARK: - Wheel, hai cột

/// Hai cột ĐỘC LẬP dưới CHUNG một plinth — cân nặng `nguyên . lẻ` chẳng hạn.
///
/// ## Vì sao là hai scroll view, không phải một layout hai cột
///
/// Với bánh xe, `contentOffset` CHÍNH LÀ state: hàng nào đang chọn = offset
/// đang ở đâu. Mà một `UIScrollView` chỉ có MỘT `contentOffset`. Hai cột cần
/// đứng ở hai chỗ khác nhau và cuộn rời nhau, nên phải là hai scroll view.
///
/// Custom layout đổi được chỗ VẼ của item, nhưng không đẻ thêm được offset thứ
/// hai. Ép một collection view làm hai cột rời thì phải tự gắn pan gesture cho
/// từng vùng, tự giữ offset ảo, rồi tự viết lại giảm tốc + rubber-band + snap
/// theo vận tốc — tức là viết tay lại đúng phần `UIScrollView` đang cho không,
/// mà đó lại là LÝ DO cả kho này chọn table/collection ngay từ đầu.
///
/// ## Cái gì chung, cái gì riêng
///
///     CHUNG    plinth, metrics, dấu ngăn ở giữa
///     RIÊNG    contentOffset, selectedIndex, gesture, momentum, haptic
///
/// Mỗi cột có `UISelectionFeedbackGenerator` riêng, nên cuộn hai cột bằng hai
/// ngón cho hai chuỗi rung độc lập — không phải gộp.
///
/// ## Hai cột này KHÔNG ràng buộc nhau
///
/// Cuộn cột nào cũng không đụng cột kia. Ca ngày sinh 3 cột mới là ca có ràng
/// buộc (đổi sang tháng 02 thì ngày 31 phải bị kẹp lại, và bánh xe phải đi
/// theo). Để cạnh nhau mới thấy ràng buộc đó tốn thêm những gì.
struct TableWheelPairPicker: View {
  var leadingValues: [String]
  @Binding var leadingIndex: Int
  var trailingValues: [String]
  @Binding var trailingIndex: Int

  /// Chữ đứng yên giữa hai cột — dấu `.` của cân nặng chẳng hạn.
  var separator: String

  var unitLabel: String = ""

  /// Hai bề rộng khác nhau vì hai cột chứa số dài ngắn khác nhau: cột nguyên
  /// phải chứa nổi "200" ở cỡ chữ 40pt, cột lẻ chỉ có một chữ số. Cho bằng nhau
  /// thì cụm số lệch hẳn sang một bên so với dấu chấm.
  var leadingWidth: CGFloat = 100
  var trailingWidth: CGFloat = 60
  var separatorWidth: CGFloat = 24

  var metrics: TableWheelMetrics = .default

  var body: some View {
    ZStack {
      WheelPlinth(unitLabel: unitLabel, height: metrics.rowHeight)

      // Cụm hai cột nằm GIỮA khung, còn nhãn đơn vị bám mép phải của plinth —
      // đúng như mockup: `60 . 0` ở giữa, `kg` tách ra bên phải.
      HStack(spacing: 0) {
        TableWheelColumn(
          values: leadingValues,
          selectedIndex: $leadingIndex,
          metrics: metrics
        )
        .frame(width: leadingWidth)

        // Cùng cỡ chữ và cùng độ đậm với hàng ở tâm, để dấu chấm nằm đúng
        // baseline của hai con số hai bên.
        Text(separator)
          .font(.system(size: metrics.fontSize, weight: .bold))
          .frame(width: separatorWidth)

        TableWheelColumn(
          values: trailingValues,
          selectedIndex: $trailingIndex,
          metrics: metrics
        )
        .frame(width: trailingWidth)
      }
    }
    .frame(height: metrics.height)
  }
}

// MARK: - Column

private struct TableWheelColumn: UIViewRepresentable {
  let values: [String]
  @Binding var selectedIndex: Int
  let metrics: TableWheelMetrics

  func makeCoordinator() -> Coordinator { Coordinator(self) }

  func makeUIView(context: Context) -> CenteredWheelTable {
    let table = CenteredWheelTable(
      rowHeight: metrics.rowHeight,
      initialRowIndex: selectedIndex
    )
    // Một object đóng cả hai vai. `dataSource` trả lời "có bao nhiêu hàng, mỗi
    // hàng chứa gì"; `delegate` trả lời "khi có sự kiện thì làm gì".
    table.dataSource = context.coordinator
    table.delegate = context.coordinator
    return table
  }

  func updateUIView(_ table: CenteredWheelTable, context: Context) {
    context.coordinator.parent = self

    // Không kéo bánh xe khi ngón tay còn chạm hoặc còn trôi — giật ngay dưới ngón.
    guard !table.isDragging, !table.isDecelerating else { return }

    // Chỗ bánh xe PHẢI ở
    let desiredOffsetY = context.coordinator.offset(forRowIndex: selectedIndex, in: table)
    guard abs(table.contentOffset.y - desiredOffsetY) > 0.5 else { return }

    // `animated: false` vì đây là SỬA CHO KHỚP, không phải một chuyển động
    // người dùng chờ xem.
    table.setContentOffset(CGPoint(x: 0, y: desiredOffsetY), animated: false)
  }

  /// Cầu nối giữa struct SwiftUI và UIKit. Tồn tại vì ba lý do độc lập:
  ///
  /// 1. `delegate` / `dataSource` của UIKit khai là `weak` → bắt buộc kiểu THAM
  ///    CHIẾU. `TableWheelColumn` là struct, gán vào đó không compile được.
  /// 2. SwiftUI huỷ và dựng lại struct mỗi lần `body` của cha chạy. Coordinator
  ///    được tạo MỘT lần và SwiftUI giữ sống suốt đời view.
  /// 3. Phải có chỗ giữ state qua các lần update — `selectionFeedback` mà tạo
  ///    mới mỗi lần là mất trạng thái `prepare()`, cú rung đầu bị trễ.
  ///
  /// Và vì `delegate` là `weak`: nếu chỉ table giữ Coordinator thì nó chết ngay.
  /// `context.coordinator` là chủ sở hữu **strong** duy nhất.
  ///
  /// Bảng phân loại 12 thành viên nằm trong thân class, ngay dưới `init`.
  ///
  /// ## Vì sao `: NSObject`
  ///
  /// Hai protocol kia là `@objc` (đến từ Objective-C), và protocol `@objc` chỉ
  /// cho class Objective-C tuân thủ. Bỏ `NSObject` là compile error.
  ///
  /// ⚠️ Hệ quả nguy hiểm: khái niệm "optional requirement" CHỈ tồn tại trong
  ///    protocol `@objc`, và UIKit kiểm tra lúc **runtime** bằng
  ///    `respondsToSelector:`. Nên **viết sai chữ ký của một hàm tuỳ chọn thì
  ///    compiler không báo gì và hàm không bao giờ được gọi**. Gõ nhầm nhãn
  ///    trong `scrollViewDidScroll` → build xanh, chạy im, bánh xe không tô đậm
  ///    và không rung, không có lỗi nào chỉ cho bạn. Luôn để autocomplete sinh
  ///    chữ ký, đừng gõ tay.
  ///
  final class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {
    var parent: TableWheelColumn
    private let selectionFeedback = UISelectionFeedbackGenerator()

    init(_ parent: TableWheelColumn) {
      self.parent = parent
    }

    /*
     Protocol trong Swift chỉ khai YÊU CẦU, không cho sẵn thân hàm — nên 9 thành
     viên dưới đây là "hiện thực", không phải "kế thừa".

     ⚠️ Tên hàm là phần TRƯỚC dấu ngoặc; phần sau là argument label. Ba hàm đầu
        đều tên `tableView`, phân biệt nhau CHỈ bằng label — nên gõ nhầm một
        label là thành một hàm khác hẳn, và với protocol @objc thì compiler
        không kêu (xem cảnh báo ở doc comment phía trên).

    ┌────────────────────────────────────────────────────────────────┬──────────────────────────────────┐
    │ Thành viên                                                     │ Nguồn                            │
    ├────────────────────────────────────────────────────────────────┼──────────────────────────────────┤
    │ tableView(_:numberOfRowsInSection:)                            │ BẮT BUỘC — UITableViewDataSource │
    │ tableView(_:cellForRowAt:)                                     │ BẮT BUỘC — UITableViewDataSource │
    │ tableView(_:willDisplay:forRowAt:)                             │ tuỳ chọn — UITableViewDelegate   │
    │ scrollViewWillEndDragging(_:withVelocity:targetContentOffset:) │ tuỳ chọn — UIScrollViewDelegate  │
    │ scrollViewDidScroll(_:)                                        │ tuỳ chọn — UIScrollViewDelegate  │
    │ scrollViewDidEndDragging(_:willDecelerate:)                    │ tuỳ chọn — UIScrollViewDelegate  │
    │ scrollViewDidEndDecelerating(_:)                               │ tuỳ chọn — UIScrollViewDelegate  │
    │ offset(forRowIndex:in:)                                        │ của mình                         │
    │ rowIndex(atOffset:in:)                                         │ của mình                         │
    │ restyle(_:in:)                                                 │ của mình                         │
    │ settle(_:)                                                     │ của mình                         │
    │ parent, selectionFeedback                                      │ của mình                         │
    └────────────────────────────────────────────────────────────────┴──────────────────────────────────┘

     BẮT BUỘC  thiếu là compile error.
     tuỳ chọn  bỏ đi vẫn build và vẫn chạy, chỉ mất hành vi.
               VD:
               Bỏ scrollViewWillEndDragging(_:withVelocity:targetContentOffset:)
               là mất snap, bánh xe dừng lửng lơ giữa hai hàng.
     của mình  không protocol nào biết tới, chỉ là helper.
     */

    // MARK: Bắt buộc — UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      parent.values.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(
        withIdentifier: WheelCell.reuseID,
        for: indexPath
      ) as! WheelCell
      cell.setText(parent.values[indexPath.row])
      return cell
    }

    // MARK: Tuỳ chọn — UITableViewDelegate

    /// Cell vừa vào màn hình mang style của hàng nó tái dùng lại.
    func tableView(
      _ tableView: UITableView,
      willDisplay cell: UITableViewCell,
      forRowAt indexPath: IndexPath
    ) {
      restyle(cell, in: tableView)
    }

    // MARK: Tuỳ chọn — UIScrollViewDelegate

    /*
     ⭐️⭐️⭐️ Snap, ngôi sao của cả file
     Thời điểm là tất cả: hàm này chạy lúc ngón tay vừa nhả, trước khi giảm tốc bắt đầu.
     UIKit đã tính xong "với vận tốc này thì nó sẽ dừng ở đây".
     Bạn nắn con số đó về tâm hàng gần nhất → quán tính tự trôi tới đúng chỗ.
     */
    func scrollViewWillEndDragging(
      _ scrollView: UIScrollView,
      withVelocity velocity: CGPoint,
      targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
      let rowIndex = self.rowIndex(atOffset: targetContentOffset.pointee.y, in: scrollView)
      targetContentOffset.pointee.y = offset(forRowIndex: rowIndex, in: scrollView)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      guard let table = scrollView as? UITableView else { return }
      for cell in table.visibleCells {
        restyle(cell, in: table)
      }

      // Chỉ ghi khi NGƯỜI DÙNG cuộn. `didScroll` còn bắn khi UIKit gán
      // `contentInset` lúc layout, và lúc đó offset chưa khớp inset nên `rowIndex`
      // ra 0 — ghi ngược cái đó là xoá mất lựa chọn ban đầu.
      guard scrollView.isDragging || scrollView.isDecelerating else { return }

      let rowIndex = self.rowIndex(atOffset: scrollView.contentOffset.y, in: scrollView)
      guard parent.selectedIndex != rowIndex else { return }
      parent.selectedIndex = rowIndex
      selectionFeedback.selectionChanged()
    }

    /// Hai hàm dưới là MÉP SAU của chuyển động — chỗ muộn nhất còn sửa được.
    /// Cả hai cùng gọi `settle`, xem lý do ở đó.
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
      // Còn trôi tiếp thì chưa phải mép sau — `didEndDecelerating` sẽ lo.
      guard !decelerate else { return }
      settle(scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
      settle(scrollView)
    }

    // MARK: Của mình

    // `rowIndex` là chỉ số 0-based vào `values` — cùng một con số với
    // `indexPath.row` bên dataSource và với `selectedIndex` bên SwiftUI.
    //
    //   offset   = rowIndex × rowHeight − contentInset.top
    //   rowIndex = round((offset + contentInset.top) / rowHeight)

    func offset(forRowIndex rowIndex: Int, in scrollView: UIScrollView) -> CGFloat {
      CGFloat(rowIndex) * parent.metrics.rowHeight - scrollView.contentInset.top
    }

    /// Kẹp về `0...count-1` vì rubber-band cho kéo QUÁ hai đầu: kéo quá đỉnh thì
    /// offset xuống dưới `−contentInset.top`, `raw` ra số âm, làm tròn thành −1,
    /// và `values[-1]` là crash.
    func rowIndex(atOffset offset: CGFloat, in scrollView: UIScrollView) -> Int {
      let raw = (offset + scrollView.contentInset.top) / parent.metrics.rowHeight
      return min(max(Int(raw.rounded()), 0), max(parent.values.count - 1, 0))
    }

    /// Kéo bánh xe về đúng hàng mà state đang nói, sau khi chuyển động đã dừng.
    ///
    /// Cần vì `updateUIView` CỐ Ý bỏ qua khi bánh xe còn kéo hoặc còn trôi. Bình
    /// thường điều đó vô hại — người dùng cuộn tới đâu thì state ghi tới đó, hai
    /// bên vốn đã khớp nên hàm này không làm gì.
    ///
    /// Nó chỉ ra tay khi state bị sửa TỪ NGOÀI đúng lúc bánh xe đang chạy: cột
    /// nguyên chạm 200 nên cột lẻ bị kẹp về 0 (xem `WeightTableWheelSheet`). Cú
    /// đẩy ấy rơi vào khoảng lặng của `updateUIView`, và nếu không có hàm này
    /// thì bánh xe nằm lại ở hàng cũ trong khi state đã đổi — state và UI nói
    /// hai chuyện khác nhau, đúng cảnh mà `externalChangeProbe` dựng ra để xem.
    ///
    /// `animated: true`, khác `updateUIView`: đây là một chỉnh sửa người dùng
    /// CẦN THẤY. Bánh xe tự trườn về 0 chính là câu trả lời cho "sao tôi chọn
    /// 200.5 mà không được".
    private func settle(_ scrollView: UIScrollView) {
      let desiredOffsetY = offset(forRowIndex: parent.selectedIndex, in: scrollView)
      guard abs(scrollView.contentOffset.y - desiredOffsetY) > 0.5 else { return }
      scrollView.setContentOffset(CGPoint(x: 0, y: desiredOffsetY), animated: true)
    }

    private func restyle(_ cell: UITableViewCell, in tableView: UITableView) {
      let rowHeight = parent.metrics.rowHeight
      guard let wheelCell = cell as? WheelCell else { return }
      // `bounds.origin` của scroll view CHÍNH LÀ contentOffset, nên `bounds.midY`
      // đã là tâm nhìn thấy trong toạ độ nội dung. Không dùng `contentInset` ở
      // đây: lúc layout đầu tiên nó chưa được gán, và tâm sẽ tính lệch.
      let centerY = tableView.bounds.midY

      // Khoảng cách tới tâm, tính bằng SỐ HÀNG. Liên tục chứ không nguyên: đang
      // cuộn giữa hai hàng thì nó là 0.5, 1.3… — nhờ vậy chữ co giãn mượt theo
      // ngón tay chứ không nhảy bậc.
      let distance = abs(cell.frame.midY - centerY) / rowHeight

      wheelCell.apply(
        scale: parent.metrics.ramp(parent.metrics.scaleRamp, at: distance),
        alpha: parent.metrics.ramp(parent.metrics.alphaRamp, at: distance),
        isCentered: distance < 0.5,
        fontSize: parent.metrics.fontSize
      )
    }

  }
}

// MARK: - Table

/// Một `UITableView` đã là bánh xe ngay từ `init`: không kẻ vạch, không thanh
/// cuộn, không chọn được, giảm tốc nhanh, cell đăng ký sẵn, và hàng đầu/cuối lên
/// được tâm.
///
/// Cấu hình nằm ở đây chứ không ở `makeUIView` vì chúng trả lời "bảng này là
/// loại gì", không phải "SwiftUI host nó ra sao". Dựng ở đâu cũng ra một bánh xe
/// hoàn chỉnh, không thể quên set thứ gì.
final class CenteredWheelTable: UITableView {
  /// Hàng phải vào tâm ở lần layout đầu tiên.
  private let initialRowIndex: Int
  private var hasAppliedInitialRowIndex = false

  init(rowHeight: CGFloat, initialRowIndex: Int) {
    self.initialRowIndex = initialRowIndex
    super.init(frame: .zero, style: .plain)

    // Tất cả gán sau `super.init` vì đều là property KẾ THỪA từ UITableView.

    // Dùng thẳng `rowHeight` của UITableView, không giữ bản sao riêng:
    // `layoutSubviews` đọc đúng con số mà UIKit dùng để đặt frame cho cell, nên
    // hai bên không thể lệch nhau.
    self.rowHeight = rowHeight

    self.separatorStyle = .none
    self.backgroundColor = .clear
    self.showsVerticalScrollIndicator = false
    self.allowsSelection = false
    // Mặc định `.normal` trôi rất xa mới dừng, đọc như trượt chứ không như bánh xe.
    self.decelerationRate = .fast

    self.register(WheelCell.self, forCellReuseIdentifier: WheelCell.reuseID)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func layoutSubviews() {
    super.layoutSubviews()

    // Đệm trên và dưới để hàng ĐẦU và hàng CUỐI cũng lên được tâm — không có nó
    // thì chúng bị chặn ở hai đầu vùng cuộn.
    let centeringInset = max(0, (bounds.height - rowHeight) / 2)

    // Gán `contentInset` tự nó kích hoạt một lượt layout — thiếu điều kiện này
    // là đệ quy vô tận.
    if contentInset.top != centeringInset {
      contentInset = UIEdgeInsets(
        top: centeringInset,
        left: 0,
        bottom: centeringInset,
        right: 0
      )
    }

    // `UIScrollView` gọi `layoutSubviews` MỖI FRAME khi cuộn. Thiếu cờ này thì
    // mỗi frame lại kéo về hàng ban đầu, bánh xe đứng im như bị dán.
    guard !hasAppliedInitialRowIndex, bounds.height > 0 else { return }
    hasAppliedInitialRowIndex = true
    setContentOffset(
      CGPoint(x: 0, y: CGFloat(initialRowIndex) * rowHeight - centeringInset),
      animated: false
    )
  }
  
  /*
                 ┌─────────────┐  ← bounds (khung nhìn), cao 300
                 │             │
centeringInset   │             │   contentInset.top = 120
120              │             │
                 ├─────────────┤
                 │   hàng 2    │  ← tâm
                 ├─────────────┤
centeringInset   │             │
120              │             │
                 └─────────────┘
   */
}

// MARK: - Cell

private final class WheelCell: UITableViewCell {
  static let reuseID = "WheelCell"

  private let label = UILabel()
  private var currentWeight: UIFont.Weight?

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    backgroundColor = .clear
    label.textAlignment = .center
    label.textColor = .label
    label.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(label)
    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  func setText(_ text: String) {
    label.text = text
  }

  /// `scale` và `alpha` liên tục; `isCentered` chỉ để chọn ĐỘ ĐẬM, vì `UIFont`
  /// không nội suy được giữa hai weight.
  ///
  /// Transform đặt lên `label`, KHÔNG lên `cell`: table tự set frame cho cell mỗi
  /// lượt layout, gán `cell.transform` là đánh nhau với nó.
  func apply(scale: CGFloat, alpha: CGFloat, isCentered: Bool, fontSize: CGFloat) {
    let weight: UIFont.Weight = isCentered ? .bold : .regular
    // Gán font mỗi frame là bắt UIKit dựng lại text layout — chỉ đổi khi cần.
    if label.font.pointSize != fontSize || currentWeight != weight {
      label.font = .systemFont(ofSize: fontSize, weight: weight)
      currentWeight = weight
    }
    label.transform = CGAffineTransform(scaleX: scale, y: scale)
    label.alpha = alpha
  }
}
