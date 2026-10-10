import Combine
import SwiftUI
import UIKit

/// Chỉ dùng cho bản so sánh: một collection view, hai lớp chữ, mask lớp primary trong cell.
final class CellMaskLayoutAttributes: UICollectionViewLayoutAttributes {
    var selectionBand: CGRect = .zero
    var unselectedAlpha: CGFloat = 1
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! CellMaskLayoutAttributes
        copy.selectionBand = selectionBand
        copy.unselectedAlpha = unselectedAlpha
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? CellMaskLayoutAttributes else { return false }
        return super.isEqual(object)
        && selectionBand == other.selectionBand
        && unselectedAlpha == other.unselectedAlpha
    }
}

private struct CellMaskGeometry: Equatable {
    var selectionBand: CGRect = .zero
    var unselectedAlpha: CGFloat = 1
}

private final class CellMaskState: ObservableObject {
    @Published var geometry = CellMaskGeometry()
}

final class CellMaskedWheelItemCell: UICollectionViewCell {
    static let reuseID = "CellMaskedWheelItemCell"
    private let maskState = CellMaskState()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setText(_ text: String, fontSize: CGFloat, rowHeight: CGFloat) {
        let maskState = maskState
        contentConfiguration = UIHostingConfiguration {
            CellMaskedWheelItemContent(
                text: text,
                fontSize: fontSize,
                rowHeight: rowHeight,
                maskState: maskState
            )
        }
        .margins(.all, 0)
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let attrs = layoutAttributes as? CellMaskLayoutAttributes else { return }
        let geometry = CellMaskGeometry(
            selectionBand: attrs.selectionBand,
            unselectedAlpha: attrs.unselectedAlpha
        )
        guard maskState.geometry != geometry else { return }
        // Chỉ cập nhật hình học; không dựng lại hosting configuration mỗi frame.
        maskState.geometry = geometry
    }
}

private struct CellMaskedWheelItemContent: View {
    let text: String
    let fontSize: CGFloat
    let rowHeight: CGFloat
    @ObservedObject var maskState: CellMaskState
    
    var body: some View {
        ZStack {
            label()
                .foregroundStyle(.gray)
                .opacity(Double(maskState.geometry.unselectedAlpha))
            
            label()
                .foregroundStyle(.primary)
                .mask(alignment: .topLeading) { selectionMask }
        }
    }
    
    private var selectionMask: some View {
        let band = maskState.geometry.selectionBand
        return Rectangle()
            .frame(width: band.width, height: band.height)
            .offset(x: band.minX, y: band.minY)
    }
    
    private func label() -> some View {
        Text(verbatim: text)
            .font(.system(size: fontSize, weight: .bold))
            .lineLimit(1)
            .frame(maxWidth: .infinity)
            .frame(height: rowHeight)
    }
}
