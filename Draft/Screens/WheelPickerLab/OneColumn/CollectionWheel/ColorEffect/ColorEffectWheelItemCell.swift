import Combine
import SwiftUI
import UIKit

final class ColorEffectWheelLayoutAttributes: UICollectionViewLayoutAttributes {
    var selectionBand: CGRect = .zero
    var unselectedAlpha: CGFloat = 1
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! ColorEffectWheelLayoutAttributes
        copy.selectionBand = selectionBand
        copy.unselectedAlpha = unselectedAlpha
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? ColorEffectWheelLayoutAttributes else { return false }
        return super.isEqual(object)
        && selectionBand == other.selectionBand
        && unselectedAlpha == other.unselectedAlpha
    }
}

private struct ColorEffectWheelGeometry: Equatable {
    var selectionBand: CGRect = .zero
    var unselectedAlpha: CGFloat = 1
}

private final class ColorEffectWheelState: ObservableObject {
    @Published var geometry = ColorEffectWheelGeometry()
}

final class ColorEffectWheelItemCell: UICollectionViewCell {
    static let reuseID = "ColorEffectWheelItemCell"
    private let shaderState = ColorEffectWheelState()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setText(_ text: String, fontSize: CGFloat, rowHeight: CGFloat) {
        let shaderState = shaderState
        contentConfiguration = UIHostingConfiguration {
            ColorEffectWheelItemContent(
                text: text,
                fontSize: fontSize,
                rowHeight: rowHeight,
                shaderState: shaderState
            )
        }
        .margins(.all, 0)
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let attrs = layoutAttributes as? ColorEffectWheelLayoutAttributes else { return }
        let geometry = ColorEffectWheelGeometry(
            selectionBand: attrs.selectionBand,
            unselectedAlpha: attrs.unselectedAlpha
        )
        guard shaderState.geometry != geometry else { return }
        // Cập nhật tham số shader, giữ nguyên hosting configuration khi cuộn.
        shaderState.geometry = geometry
    }
}

private struct ColorEffectWheelItemContent: View {
    let text: String
    let fontSize: CGFloat
    let rowHeight: CGFloat
    @ObservedObject var shaderState: ColorEffectWheelState
    
    var body: some View {
        let geometry = shaderState.geometry
        
        Text(verbatim: text)
            .font(.system(size: fontSize, weight: .bold))
            .foregroundStyle(.primary)
            .lineLimit(1)
            .frame(maxWidth: .infinity)
            .frame(height: rowHeight)
            .colorEffect(
                ShaderLibrary.wheelSelectionColor(
                    .float2(geometry.selectionBand.minY, geometry.selectionBand.maxY),
                    .color(.gray),
                    .float(geometry.unselectedAlpha)
                )
            )
    }
}
