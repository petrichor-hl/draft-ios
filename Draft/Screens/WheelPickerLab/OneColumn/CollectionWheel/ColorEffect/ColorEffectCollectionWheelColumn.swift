import SwiftUI
import UIKit

// MARK: - Column

/// Một danh sách; mỗi cell có một lớp chữ đổi màu bằng shader colorEffect.
struct ColorEffectCollectionWheelColumn: UIViewRepresentable {
    let values: [String]
    @Binding var selectedIndex: Int
    let metrics: CollectionWheelMetrics
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func makeUIView(context: Context) -> ColorEffectWheelCollectionView {
        let view = ColorEffectWheelCollectionView(
            metrics: metrics,
            initialRowIndex: selectedIndex
        )
        view.dataSource = context.coordinator
        view.delegate = context.coordinator
        return view
    }
    
    func updateUIView(_ view: ColorEffectWheelCollectionView, context: Context) {
        let valuesChanged = context.coordinator.parent.values != values
        context.coordinator.parent = self
        
        // Cập nhật số item trước khi căn offset.
        // Cột ngày có thể đổi 31 → 28 → 31 trong khi view vẫn được tái sử dụng.
        if valuesChanged {
            view.reloadData()
            view.layoutIfNeeded()
        }
        
        guard !view.isDragging, !view.isDecelerating else { return }
        
        let desiredOffsetY = context.coordinator.offset(forRowIndex: selectedIndex, in: view)
        guard abs(view.contentOffset.y - desiredOffsetY) > 0.5 else { return }
        view.setContentOffset(CGPoint(x: 0, y: desiredOffsetY), animated: false)
    }
    
    /// Coordinator lo selection, snap và haptics của danh sách duy nhất.
    final class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
        var parent: ColorEffectCollectionWheelColumn
        private let selectionFeedback = UISelectionFeedbackGenerator()
        
        init(_ parent: ColorEffectCollectionWheelColumn) {
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
                withReuseIdentifier: ColorEffectWheelItemCell.reuseID,
                for: indexPath
            ) as! ColorEffectWheelItemCell
            cell.setText(
                parent.values[indexPath.item],
                fontSize: parent.metrics.fontSize,
                rowHeight: parent.metrics.rowHeight
            )
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
        
        /// Mép sau của chuyển động, để cú kẹp từ cột kia không rơi vào khoảng lặng
        /// của `updateUIView` — chép nguyên từ bản table, xem `settle` ở đó.
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            guard !decelerate else { return }
            settle(scrollView)
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            settle(scrollView)
        }
        
        // MARK: Của mình
        
        func offset(forRowIndex rowIndex: Int, in scrollView: UIScrollView) -> CGFloat {
            CGFloat(rowIndex) * parent.metrics.rowHeight - scrollView.contentInset.top
        }
        
        func rowIndex(atOffset offset: CGFloat, in scrollView: UIScrollView) -> Int {
            let raw = (offset + scrollView.contentInset.top) / parent.metrics.rowHeight
            return min(max(Int(raw.rounded()), 0), max(parent.values.count - 1, 0))
        }
        
        /// Không đổi một chữ so với bản table — nó chỉ đụng tới `contentOffset` và
        /// lưới DANH NGHĨA, mà hai thứ đó bản collection vẫn giữ đều y hệt. Phần
        /// nén chỉ ảnh hưởng cách VẼ nên không liên quan.
        private func settle(_ scrollView: UIScrollView) {
            let desiredOffsetY = offset(forRowIndex: parent.selectedIndex, in: scrollView)
            guard abs(scrollView.contentOffset.y - desiredOffsetY) > 0.5 else { return }
            scrollView.setContentOffset(CGPoint(x: 0, y: desiredOffsetY), animated: true)
        }
    }
}

// MARK: - Layout

private final class ColorEffectWheelLayout: UICollectionViewLayout {
    private let metrics: CollectionWheelMetrics
    
    init(metrics: CollectionWheelMetrics) {
        self.metrics = metrics
        super.init()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
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
        let attrs = ColorEffectWheelLayoutAttributes(forCellWith: indexPath)
        
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
        let signedDrawn = signedDistance < 0 ? -drawn : drawn
        let scale = metrics.ramp(metrics.scaleRamp, at: distance)
        
        attrs.frame = CGRect(
            x: 0,
            y: viewportCenterY + signedDrawn - metrics.rowHeight / 2,
            width: collectionView.bounds.width,
            height: metrics.rowHeight
        )
        attrs.transform = CGAffineTransform(scaleX: scale, y: scale)
        // Alpha của cell luôn là 1; chỉ chữ gray bên ngoài vùng chọn dùng alphaRamp.
        // Đổi dải chọn cố định về toạ độ cell trước transform.
        attrs.selectionBand = CGRect(
            x: 0,
            y: metrics.rowHeight / 2 + (-metrics.centerRowHeight / 2 - signedDrawn) / scale,
            width: collectionView.bounds.width,
            height: metrics.centerRowHeight / scale
        )
        attrs.unselectedAlpha = metrics.ramp(metrics.alphaRamp, at: distance)
        return attrs
    }
}

// MARK: - Collection view

final class ColorEffectWheelCollectionView: UICollectionView {
    private let wheelRowHeight: CGFloat
    private let initialRowIndex: Int
    
    private var hasAppliedInitialRowIndex = false
    
    init(metrics: CollectionWheelMetrics, initialRowIndex: Int) {
        self.wheelRowHeight = metrics.rowHeight
        self.initialRowIndex = initialRowIndex
        super.init(frame: .zero, collectionViewLayout: ColorEffectWheelLayout(metrics: metrics))
        
        backgroundColor = .clear
        showsVerticalScrollIndicator = false
        // Mặc định `.normal` trôi rất xa mới dừng, đọc như trượt chứ không như bánh xe.
        decelerationRate = .fast
        register(ColorEffectWheelItemCell.self, forCellWithReuseIdentifier: ColorEffectWheelItemCell.reuseID)
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
