import SwiftUI

// Công thức tính tiến độ cuộn bằng GeometryReader + PreferenceKey:
// - contentFrame: Frame của toàn bộ nội dung trong coordinate space của ScrollView.
// - contentFrame.minY là tọa độ Y của mép trên nội dung, đo tương đối với ScrollView.
//
// - viewportHeight: Chiều cao vùng chứa để xem nội dung, không bao gồm header.
// - distance = -contentFrame.minY (cuộn xuống thì nội dung đi lên, minY âm).
// - scrollableHeight = contentFrame.height - viewportHeight.
// - progress = clamp(distance / scrollableHeight, 0...1).
//
// Khi viewportHeight <= 0 hoặc scrollableHeight <= 0, quy ước progress = 0.
// Không cộng thêm contentInsets vào mẫu số với cách đo này.

struct ScrollProgressBarScreen_iOS_17: View {
    @State private var contentFrame: CGRect = .zero
    @State private var viewportHeight: CGFloat = 0
    
    // Tên riêng cho hệ tọa độ của ScrollView.
    @Namespace private var scrollSpace
    
    private var progress: Double {
        let scrollableHeight = contentFrame.height - viewportHeight
        
        guard viewportHeight > 0, scrollableHeight > 0 else {
            return 0
        }
        
        let distance = -contentFrame.minY
        let fraction = distance / scrollableHeight
        
        return Double(min(max(fraction, 0), 1))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header nằm ngoài vùng cuộn.
            VStack(spacing: 8) {
                Text(
                    progress,
                    format: .percent.precision(.fractionLength(0))
                )
                .monospacedDigit()
                
                ProgressView(value: progress, total: 1)
                    .tint(.blue)
            }
            .padding()
            
            ScrollView {
                Text(sampleText)
                    .padding(.horizontal)
                    .background {
                        // Đo toàn bộ nội dung và vị trí của nó trong viewport.
                        GeometryReader { geometry in
                            Color.clear
                                .preference(
                                    key: ContentFrameKey.self,
                                    value: geometry.frame(in: .named(scrollSpace))
                                )
                                .onPreferenceChange(ContentFrameKey.self) { newFrame in
                                    contentFrame = newFrame
                                }
                        }
                    }
            }
            .coordinateSpace(name: scrollSpace)
            .background {
                GeometryReader { viewport in
                    Color.clear
                        .preference(
                            key: ViewportHeightKey.self,
                            value: viewport.size.height
                        )
                        .onPreferenceChange(ViewportHeightKey.self) { newHeight in
                            viewportHeight = newHeight
                        }
                }
            }
        }
        .navigationTitle("Progress · iOS and earlier")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - PreferenceKey
// PreferenceKey truyền số đo từ view con lên view cha. Mỗi key trong demo này có một nguồn đo:

private struct ContentFrameKey: PreferenceKey {     // vị trí và chiều cao toàn bộ nội dung.
    static var defaultValue: CGRect { .zero }
    
    static func reduce(
        value: inout CGRect,
        nextValue: () -> CGRect
    ) {
        value = nextValue()
    }
}

private struct ViewportHeightKey: PreferenceKey {   // chiều cao vùng chứa để xem nội dung.
    static var defaultValue: CGFloat { 0 }
    
    static func reduce(
        value: inout CGFloat,
        nextValue: () -> CGFloat
    ) {
        value = nextValue()
    }
}

private let sampleText = """
                    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum laoreet ante quis tortor euismod, vitae eleifend metus pretium. Nam eget pellentesque quam, quis molestie lacus. Mauris accumsan pharetra ultrices. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Curabitur accumsan finibus auctor. Maecenas ut libero at ipsum elementum laoreet. Nullam accumsan faucibus nisl sit amet luctus. Proin eu nisi et justo condimentum tristique. Proin sodales fringilla est, ac pellentesque diam porttitor sit amet. Pellentesque quis varius ligula. Pellentesque ut justo augue. Nullam aliquam lacus a metus aliquet, ut venenatis ex faucibus. Praesent at libero nec est ornare placerat. Proin gravida vehicula neque, non dignissim metus blandit ut. Vestibulum rutrum odio nec massa volutpat, in cursus ex sodales. Sed at sapien posuere, ornare nulla ut, convallis lorem.
                    
                    Nunc at justo sit amet mauris eleifend molestie vitae ut orci. Donec eget enim vitae tellus pretium vulputate. Praesent ornare commodo nisi, ac convallis nulla vehicula sit amet. Praesent a justo nisl. Cras nec tincidunt massa, quis dignissim lorem. Aliquam non ante at purus vestibulum eleifend. Cras ipsum lacus, vestibulum et rutrum vel, vehicula vel nibh. Nulla efficitur, ante id molestie rhoncus, metus arcu molestie augue, auctor elementum mi felis sed lorem.
                    
                    Sed volutpat orci massa, sed iaculis ipsum condimentum sed. Quisque cursus, elit semper auctor sollicitudin, urna diam rhoncus elit, sollicitudin tincidunt enim velit mattis orci. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin hendrerit sit amet purus et viverra. Morbi malesuada, libero nec lacinia auctor, erat sapien pharetra libero, nec eleifend enim felis et metus. Nulla hendrerit magna tortor, sit amet fermentum metus vestibulum sed. Morbi faucibus enim id tristique scelerisque. Quisque porta mi a porta imperdiet. Cras gravida mollis velit, et tempor turpis elementum mattis. Vivamus dictum id justo sit amet laoreet. Mauris interdum dolor a mi ullamcorper pellentesque. Aliquam nunc sapien, viverra vel orci non, consequat pellentesque mauris. Phasellus convallis consectetur eros, eu lobortis justo. Praesent massa erat, interdum eget mi in, dictum viverra augue. Cras ultrices felis at sollicitudin scelerisque.
                    
                    Phasellus mattis lacus nec rhoncus dapibus. Nunc aliquam porttitor magna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Integer congue felis quis ligula placerat ultricies. Vivamus neque lorem, pulvinar sed velit sed, dignissim blandit dui. Aliquam vitae ullamcorper velit. Praesent enim arcu, interdum eu risus a, sodales scelerisque magna. Suspendisse vestibulum sollicitudin augue nec auctor. Maecenas venenatis, sem eu vestibulum dignissim, dui lectus condimentum ex, ut pretium erat eros nec dui. Duis eget purus ac ante ultrices posuere. Etiam porttitor enim eu nunc consequat pretium. Integer scelerisque bibendum lectus, ac laoreet felis venenatis sed. Integer sit amet tortor at nisi convallis pharetra. Etiam a ante pulvinar, congue ipsum sed, faucibus elit. Nullam feugiat, velit eget mattis congue, sem ipsum eleifend dui, at efficitur nisi dui quis ex. Duis lacus purus, volutpat vitae bibendum a, ultricies sit amet lectus.
                    """
