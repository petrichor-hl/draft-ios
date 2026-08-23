//
//  CollectionWheelPicker.swift
//  Draft
//
//  Bánh xe một cột, dựng trên UICollectionView + custom layout.
//
//  Khác `TableWheelPicker` đúng MỘT điều: hàng ở rìa không chỉ nhỏ lại mà còn
//  XÍCH SÁT vào tâm. `UITableView` không làm được vì `transform` chỉ đổi cách vẽ,
//  hàng vẫn chiếm nguyên `rowHeight`.
//
//  Mọi thứ khác giữ nguyên — vì `UICollectionView` cũng kế thừa `UIScrollView`,
//  nên `scrollViewWillEndDragging`, `contentInset`, momentum, snap đều y hệt.
//
//  ⚠️ CHỈ DÙNG API iOS 16.
//

import SwiftUI
import UIKit

// MARK: - Metrics

/// Số đo của RIÊNG bản collection.
///
/// Cố ý không dùng chung với bản table — xem ghi chú ở `TableWheelMetrics`.
///
/// ## Hai nghĩa của "chiều cao hàng" — tách ra là hiểu hết
///
///     BƯỚC CUỘN     `rowHeight`, ĐỀU cho mọi hàng.
///                   Dùng cho `contentSize`, snap, `contentInset`.
///
///     CHIỀU CAO VẼ  `rowHeightRamp`, KHÁC nhau theo vòng.
///                   Chỉ layout biết, chỉ ảnh hưởng hình.
///
/// Mỗi hàng chiếm đúng `rowHeight` quãng cuộn bất kể được vẽ to hay nhỏ. Đây là
/// cách `UIPickerView` làm: lưới cuộn đều, chỉ CÁCH VẼ bị bóp méo — hàng nằm
/// trên mặt hình trụ nên càng xoay ra xa càng dẹt.
///
/// Giữ lưới cuộn đều bảo toàn một bất biến: hàng ở tâm có khoảng cách 0, mà hàm
/// nén luôn cho f(0) = 0 — nên chỗ bánh xe DỪNG và chỗ hàng đó ĐƯỢC VẼ luôn
/// trùng nhau, không sai số tích luỹ dù cuộn qua bao nhiêu hàng.
struct CollectionWheelMetrics {
  /// Chiều cao VẼ của hàng theo vòng tính từ tâm: [tâm, kề, xa…].
  /// Phần tử cuối áp dụng cho mọi vòng xa hơn.
  ///
  /// Chỉ chi phối VỊ TRÍ (bước cuộn và lượng nén). Cỡ chữ do `scaleRamp` lo
  /// riêng — xem ghi chú ở đó.
  var rowHeightRamp: [CGFloat] = [64, 60, 52]

  var visibleRows: Int = 5
  var fontSize: CGFloat = 40

  /// Tỉ lệ co CHỮ theo vòng.
  ///
  /// Property riêng, KHÔNG suy ra từ `rowHeightRamp` — dù ban đầu từng làm vậy.
  /// Hai mảng đo hai đại lượng khác nhau và cần chỉnh độc lập:
  ///
  ///     rowHeightRamp  → khoảng cách giữa các hàng bị nén bao nhiêu
  ///     scaleRamp      → chữ nhỏ đi bao nhiêu
  ///
  /// Chứng cứ chúng độc lập: đổi ramp từ [44,40,32] sang [64,60,52] thì lượng
  /// nén KHÔNG đổi (vẫn kéo vào 6 và 16pt) vì nén phụ thuộc HIỆU giữa các chiều
  /// cao; nhưng tỉ lệ co lại nhẹ hẳn (0.727 → 0.813) vì tỉ lệ phụ thuộc THƯƠNG.
  /// Buộc chúng vào một mảng thì mỗi lần chỉnh cái này lại hỏng cái kia.
  var scaleRamp: [CGFloat] = [1, 0.85, 0.62]

  /// Độ mờ theo vòng. Cũng để riêng, cùng lý do.
  var alphaRamp: [CGFloat] = [1, 0.3, 0.2]

  static let `default` = CollectionWheelMetrics()

  // MARK: - Suy ra

  /// Bước cuộn danh nghĩa = khoảng cách TÂM giữa hàng giữa và hàng kề nó.
  ///
  /// Chọn đúng con số này để hàng đang chọn và hai hàng kề bám ngón tay **1:1**;
  /// nén chỉ bắt đầu từ vòng 2 trở ra, nơi mắt không soi. Lấy số khác (64 chẳng
  /// hạn) thì ngay vùng trung tâm đã lệch — chỗ tệ nhất để có sai số.
  var rowHeight: CGFloat { (drawnHeight(atRing: 0) + drawnHeight(atRing: 1)) / 2 }

  /// Chiều cao hàng ở tâm — dùng cho plinth.
  var centerRowHeight: CGFloat { drawnHeight(atRing: 0) }

  /// Chiều cao khung để `visibleRows` hàng hiện ĐỦ, không hàng nào cụt.
  ///
  /// ⚠️ KHÔNG phải `visibleRows × rowHeight`. Đó là quãng CUỘN, còn đây là quãng
  ///    VẼ — mà vẽ thì đã bị nén. Lấy nhầm công thức kia thì khung rộng dư và
  ///    hàng thứ 6 ló lên một nửa ở mép.
  ///
  ///    Với [64, 60, 52] và 5 hàng: vòng ngoài cùng là 2, tâm ở 118, nửa chiều
  ///    cao 26 → mép ngoài 144 → khung 288. (Lưới đều sẽ là 5 × 62 = 310.)
  var height: CGFloat {
    let outerRing = max(visibleRows - 1, 0) / 2
    return 2 * (ringCenter(outerRing) + drawnHeight(atRing: outerRing) / 2)
  }

  func drawnHeight(atRing ring: Int) -> CGFloat {
    rowHeightRamp[min(max(ring, 0), rowHeightRamp.count - 1)]
  }

  // MARK: - Bóp méo vị trí

  /// Tâm hàng khi VẼ cách tâm khung nhìn bao nhiêu điểm, cho khoảng cách danh
  /// nghĩa `distance` (đơn vị: số hàng, số thực).
  ///
  /// Cộng dồn nửa-chiều-cao dọc đường:
  ///
  ///     vòng 0: 0
  ///     vòng 1: 64/2 + 60/2 = 62
  ///     vòng 2: 62 + 60/2 + 52/2 = 118     (lưới đều sẽ là 124 → kéo vào 6)
  ///     vòng 3: 118 + 52 = 170             (lưới đều sẽ là 186 → kéo vào 16)
  ///
  /// `distance` là số thực vì lúc cuộn nó ở giữa hai vòng — nội suy tuyến tính
  /// để chuyển động liên tục chứ không nhảy bậc.
  func drawnOffset(fromCenter distance: CGFloat) -> CGFloat {
    let clamped = max(distance, 0)
    let lower = Int(clamped)
    let t = clamped - CGFloat(lower)
    let a = ringCenter(lower)
    return a + (ringCenter(lower + 1) - a) * t
  }

  /// Nội suy tuyến tính trên một thang rời rạc theo vòng.
  func ramp(_ values: [CGFloat], at distance: CGFloat) -> CGFloat {
    guard let last = values.last else { return 1 }
    let clamped = min(max(distance, 0), CGFloat(values.count - 1))
    let lower = Int(clamped)
    guard lower + 1 < values.count else { return last }
    let t = clamped - CGFloat(lower)
    return values[lower] + (values[lower + 1] - values[lower]) * t
  }

  /// Tâm của vòng thứ `ring`, tính từ tâm khung nhìn.
  private func ringCenter(_ ring: Int) -> CGFloat {
    guard ring > 0 else { return 0 }
    var y: CGFloat = 0
    for i in 1...ring {
      y += (drawnHeight(atRing: i - 1) + drawnHeight(atRing: i)) / 2
    }
    return y
  }
}

// MARK: - Wheel

struct CollectionWheelPicker: View {
  var values: [String]
  @Binding var selectedIndex: Int
  /// Bỏ trống cho cột TRẦN (năm sinh chẳng hạn). Plinth vẫn vẽ, vì nó là
  /// vạch chỉ chỗ đang chọn chứ không phải nền cho chữ đơn vị.
  var unitLabel: String = ""
  var metrics: CollectionWheelMetrics = .default

  var body: some View {
    ZStack {
      WheelPlinth(unitLabel: unitLabel, height: metrics.centerRowHeight)

      CollectionWheelColumn(
        values: values,
        selectedIndex: $selectedIndex,
        metrics: metrics
      )
    }
    .frame(height: metrics.height)
  }
}

// MARK: - Column

private struct CollectionWheelColumn: UIViewRepresentable {
  let values: [String]
  @Binding var selectedIndex: Int
  let metrics: CollectionWheelMetrics

  func makeCoordinator() -> Coordinator { Coordinator(self) }

  func makeUIView(context: Context) -> CenteredWheelCollectionView {
    let view = CenteredWheelCollectionView(
      metrics: metrics,
      initialRowIndex: selectedIndex
    )
    view.dataSource = context.coordinator
    view.delegate = context.coordinator
    return view
  }

  func updateUIView(_ view: CenteredWheelCollectionView, context: Context) {
    context.coordinator.parent = self

    guard !view.isDragging, !view.isDecelerating else { return }

    let desiredOffsetY = context.coordinator.offset(forRowIndex: selectedIndex, in: view)
    guard abs(view.contentOffset.y - desiredOffsetY) > 0.5 else { return }
    view.setContentOffset(CGPoint(x: 0, y: desiredOffsetY), animated: false)
  }

  /// Giống hệt Coordinator của bản table, trừ hai điểm:
  ///
  /// - tên method đổi theo protocol (`numberOfItemsInSection`, `cellForItemAt`)
  /// - **không còn `restyle`**: scale và alpha giờ là thuộc tính của item do
  ///   layout trả về, UIKit tự áp. Nhờ đó hết luôn hai chỗ khó chịu — không phải
  ///   nhớ tô lại ở `willDisplay`, và không còn cảnh cell tái dùng mang style của
  ///   hàng cũ trong một frame.
  final class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    var parent: CollectionWheelColumn
    private let selectionFeedback = UISelectionFeedbackGenerator()

    init(_ parent: CollectionWheelColumn) {
      self.parent = parent
    }

    // MARK: Bắt buộc — UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      parent.values.count
    }

    func collectionView(
      _ collectionView: UICollectionView,
      cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: WheelItemCell.reuseID,
        for: indexPath
      ) as! WheelItemCell
      cell.setText(parent.values[indexPath.item], fontSize: parent.metrics.fontSize)
      return cell
    }

    // MARK: Tuỳ chọn — UIScrollViewDelegate

    /// Không đổi một chữ so với bản table — `UICollectionView` cũng là
    /// `UIScrollView`, và snap chạy trên lưới DANH NGHĨA vốn vẫn đều.
    func scrollViewWillEndDragging(
      _ scrollView: UIScrollView,
      withVelocity velocity: CGPoint,
      targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
      let rowIndex = self.rowIndex(atOffset: targetContentOffset.pointee.y, in: scrollView)
      targetContentOffset.pointee.y = offset(forRowIndex: rowIndex, in: scrollView)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      // Chỉ ghi khi NGƯỜI DÙNG cuộn — `didScroll` còn bắn khi UIKit gán
      // `contentInset` lúc layout, và lúc đó offset chưa khớp inset.
      guard scrollView.isDragging || scrollView.isDecelerating else { return }

      let rowIndex = self.rowIndex(atOffset: scrollView.contentOffset.y, in: scrollView)
      guard parent.selectedIndex != rowIndex else { return }
      parent.selectedIndex = rowIndex
      selectionFeedback.selectionChanged()
    }

    // MARK: Của mình

    func offset(forRowIndex rowIndex: Int, in scrollView: UIScrollView) -> CGFloat {
      CGFloat(rowIndex) * parent.metrics.rowHeight - scrollView.contentInset.top
    }

    func rowIndex(atOffset offset: CGFloat, in scrollView: UIScrollView) -> Int {
      let raw = (offset + scrollView.contentInset.top) / parent.metrics.rowHeight
      return min(max(Int(raw.rounded()), 0), max(parent.values.count - 1, 0))
    }
  }
}

// MARK: - Layout

/// Nơi duy nhất khác biệt so với bản table.
///
/// Nó phá được vòng tròn "chiều cao → vị trí → chiều cao" bằng cách tách hai thứ:
///
///     contentSize   cố định = count × rowHeight        ← cuộn chạy trên đây
///     vị trí VẼ     hàm của contentOffset               ← chỉ ảnh hưởng hình
///
/// `shouldInvalidateLayout(forBoundsChange:)` trả `true` nên mỗi frame cuộn là
/// một lượt tính lại — đó là điều khiến "vị trí vẽ phụ thuộc offset" khả thi.
final class WheelFlowLayout: UICollectionViewLayout {
  private let metrics: CollectionWheelMetrics

  init(metrics: CollectionWheelMetrics) {
    self.metrics = metrics
    super.init()
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  /// Attributes mang thêm `isCentered`, vì độ ĐẬM của font không nội suy được
  /// nên không thể gói vào `transform` hay `alpha`.
  override class var layoutAttributesClass: AnyClass { WheelLayoutAttributes.self }

  private var itemCount: Int {
    collectionView?.numberOfItems(inSection: 0) ?? 0
  }

  override var collectionViewContentSize: CGSize {
    CGSize(
      width: collectionView?.bounds.width ?? 0,
      height: CGFloat(itemCount) * metrics.rowHeight
    )
  }

  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool { true }

  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    guard let collectionView, itemCount > 0 else { return nil }

    // Không duyệt cả mảng: cột cân nặng có thể vài nghìn hàng, mà hàm này chạy
    // MỖI FRAME. Chỉ tính quanh tâm.
    //
    // Cận trên an toàn: mỗi vòng đẩy ra ít nhất `minRowHeight` điểm, nên số vòng
    // lọt vào nửa khung nhìn không quá `nửa chiều cao / minRowHeight`.
    let minRowHeight = max(metrics.rowHeightRamp.min() ?? metrics.rowHeight, 1)
    let ringSpan = Int((collectionView.bounds.height / 2 / minRowHeight).rounded(.up)) + 2

    let centerItem = Int(collectionView.bounds.midY / metrics.rowHeight)
    let lower = max(centerItem - ringSpan, 0)
    let upper = min(centerItem + ringSpan, itemCount - 1)
    guard lower <= upper else { return nil }

    return (lower...upper).compactMap {
      layoutAttributesForItem(at: IndexPath(item: $0, section: 0))
    }
  }

  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    guard let collectionView else { return nil }
    let attrs = WheelLayoutAttributes(forCellWith: indexPath)

    // Tâm DANH NGHĨA của item, trong toạ độ nội dung. Lưới này luôn đều.
    let nominalCenterY = (CGFloat(indexPath.item) + 0.5) * metrics.rowHeight

    // `bounds.origin` của scroll view CHÍNH LÀ contentOffset, nên `midY` đã là
    // tâm khung nhìn trong cùng hệ toạ độ.
    let viewportCenterY = collectionView.bounds.midY

    // Khoảng cách tính bằng SỐ HÀNG, có dấu.
    let signedDistance = (nominalCenterY - viewportCenterY) / metrics.rowHeight
    let distance = abs(signedDistance)

    // Bóp méo: vẽ gần tâm hơn chỗ lưới đều chỉ định.
    let drawn = metrics.drawnOffset(fromCenter: distance)

    attrs.frame = CGRect(
      x: 0,
      y: viewportCenterY + (signedDistance < 0 ? -drawn : drawn) - metrics.rowHeight / 2,
      width: collectionView.bounds.width,
      height: metrics.rowHeight
    )
    attrs.transform = CGAffineTransform(
      scaleX: metrics.ramp(metrics.scaleRamp, at: distance),
      y: metrics.ramp(metrics.scaleRamp, at: distance)
    )
    attrs.alpha = metrics.ramp(metrics.alphaRamp, at: distance)
    attrs.isCentered = distance < 0.5
    return attrs
  }
}

/// `copy(with:)` và `isEqual` PHẢI được override khi thêm thuộc tính: UIKit chép
/// attributes trong lúc layout, và so sánh chúng để quyết định có vẽ lại không.
/// Thiếu `copy` thì thuộc tính mới bị mất; thiếu `isEqual` thì độ đậm không đổi
/// khi hàng đi qua tâm.
final class WheelLayoutAttributes: UICollectionViewLayoutAttributes {
  var isCentered = false

  override func copy(with zone: NSZone? = nil) -> Any {
    let copy = super.copy(with: zone) as! WheelLayoutAttributes
    copy.isCentered = isCentered
    return copy
  }

  override func isEqual(_ object: Any?) -> Bool {
    guard let other = object as? WheelLayoutAttributes else { return false }
    return super.isEqual(object) && other.isCentered == isCentered
  }
}

// MARK: - Collection view

/// Đối xứng với `CenteredWheelTable`: tự cấu hình đầy đủ trong `init`, và tự căn
/// hàng đầu/cuối vào tâm bằng `contentInset`.
final class CenteredWheelCollectionView: UICollectionView {
  private let wheelRowHeight: CGFloat
  private let initialRowIndex: Int

  private var hasAppliedInitialRowIndex = false

  init(metrics: CollectionWheelMetrics, initialRowIndex: Int) {
    self.wheelRowHeight = metrics.rowHeight
    self.initialRowIndex = initialRowIndex
    super.init(frame: .zero, collectionViewLayout: WheelFlowLayout(metrics: metrics))

    backgroundColor = .clear
    showsVerticalScrollIndicator = false
    // Mặc định `.normal` trôi rất xa mới dừng, đọc như trượt chứ không như bánh xe.
    decelerationRate = .fast
    register(WheelItemCell.self, forCellWithReuseIdentifier: WheelItemCell.reuseID)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func layoutSubviews() {
    super.layoutSubviews()

    // Đệm trên/dưới để hàng ĐẦU và hàng CUỐI cũng lên được tâm.
    let centeringInset = max(0, (bounds.height - wheelRowHeight) / 2)
    if contentInset.top != centeringInset {
      contentInset = UIEdgeInsets(
        top: centeringInset,
        left: 0,
        bottom: centeringInset,
        right: 0
      )
    }

    guard !hasAppliedInitialRowIndex, bounds.height > 0 else { return }
    hasAppliedInitialRowIndex = true
    setContentOffset(
      CGPoint(x: 0, y: CGFloat(initialRowIndex) * wheelRowHeight - centeringInset),
      animated: false
    )
  }
}

// MARK: - Cell

private final class WheelItemCell: UICollectionViewCell {
  static let reuseID = "WheelItemCell"

  private let label = UILabel()
  private var currentWeight: UIFont.Weight?

  override init(frame: CGRect) {
    super.init(frame: frame)
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

  func setText(_ text: String, fontSize: CGFloat) {
    label.text = text
    self.fontSize = fontSize
  }

  private var fontSize: CGFloat = 40

  /// UIKit gọi hàm này với attributes do layout trả về. Bản mặc định đã tự áp
  /// `frame`, `transform`, `alpha` — nên ở đây chỉ còn phần layout không gói được.
  override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
    super.apply(layoutAttributes)
    guard let attrs = layoutAttributes as? WheelLayoutAttributes else { return }
    let weight: UIFont.Weight = attrs.isCentered ? .bold : .regular
    guard currentWeight != weight || label.font.pointSize != fontSize else { return }
    label.font = .systemFont(ofSize: fontSize, weight: weight)
    currentWeight = weight
  }
}
