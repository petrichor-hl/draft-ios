#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] half4 wheelSelectionColor(
                                           float2 position,
                                           half4 color,
                                           float2 selectionBand,
                                           half4 unselectedColor,
                                           float unselectedAlpha
                                           ) {
    if (position.y >= selectionBand.x && position.y < selectionBand.y) {
        return color;
    }
    
    // Giữ alpha của nét chữ; màu trả về phải được premultiply theo alpha.
    return unselectedColor * (color.a * half(unselectedAlpha));
}
