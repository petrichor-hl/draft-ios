// Các giá trị của ScrollGeometry dùng để tính tiến độ cuộn dọc (đơn vị: pt):
// - contentSize.height: Chiều cao toàn bộ nội dung bên trong scroll view,
//   kể cả phần nằm ngoài khung nhìn; chưa cộng contentInsets.
// - contentInsets.top: Khoảng chừa thêm phía trên khối nội dung do scroll view áp dụng.
// - contentInsets.bottom: Khoảng chừa thêm phía dưới khối nội dung do scroll view áp dụng.
// - containerSize.height: Chiều cao viewport đã trừ top và bottom contentInsets,
//   không phải chiều cao toàn bộ khung UIScrollView bên dưới.
//   Quãng đường có thể cuộn = contentSize.height - containerSize.height;
//   không cộng contentInsets lần nữa để tránh tính dư.
//
//  Apple Documentation: https://developer.apple.com/documentation/swiftui/view/onscrollgeometrychange(for:of:action:)

import SwiftUI

@available(iOS 18.0, *)
struct ScrollProgressBarScreen_iOS_18: View {
    @State private var progress = 0.0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header nằm ngoài ScrollView nên luôn đứng yên.
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
            }
            .trackScrollProgress($progress)
        }
        .navigationTitle("Progress · iOS 18+")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension View {
    func trackScrollProgress(
        _ progress: Binding<Double>
    ) -> some View {
        onScrollGeometryChange(for: Double.self) { geometry in
            let distance = geometry.contentInsets.top + geometry.contentOffset.y
            
            let scrollableHeight = geometry.contentSize.height - geometry.containerSize.height
            
            // Nội dung vừa hoặc ngắn hơn viewport: không cần cuộn.
            guard scrollableHeight > 0 else { return 0 }
            
            let fraction = distance / scrollableHeight
            
            // Bounce có thể làm fraction âm hoặc lớn hơn 1.
            return Double(min(max(fraction, 0), 1))
        } action: { _, newProgress in
            progress.wrappedValue = newProgress
        }
    }
}

private let sampleText = """
                    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum laoreet ante quis tortor euismod, vitae eleifend metus pretium. Nam eget pellentesque quam, quis molestie lacus. Mauris accumsan pharetra ultrices. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Curabitur accumsan finibus auctor. Maecenas ut libero at ipsum elementum laoreet. Nullam accumsan faucibus nisl sit amet luctus. Proin eu nisi et justo condimentum tristique. Proin sodales fringilla est, ac pellentesque diam porttitor sit amet. Pellentesque quis varius ligula. Pellentesque ut justo augue. Nullam aliquam lacus a metus aliquet, ut venenatis ex faucibus. Praesent at libero nec est ornare placerat. Proin gravida vehicula neque, non dignissim metus blandit ut. Vestibulum rutrum odio nec massa volutpat, in cursus ex sodales. Sed at sapien posuere, ornare nulla ut, convallis lorem.
                    
                    Nunc at justo sit amet mauris eleifend molestie vitae ut orci. Donec eget enim vitae tellus pretium vulputate. Praesent ornare commodo nisi, ac convallis nulla vehicula sit amet. Praesent a justo nisl. Cras nec tincidunt massa, quis dignissim lorem. Aliquam non ante at purus vestibulum eleifend. Cras ipsum lacus, vestibulum et rutrum vel, vehicula vel nibh. Nulla efficitur, ante id molestie rhoncus, metus arcu molestie augue, auctor elementum mi felis sed lorem.
                    
                    Sed volutpat orci massa, sed iaculis ipsum condimentum sed. Quisque cursus, elit semper auctor sollicitudin, urna diam rhoncus elit, sollicitudin tincidunt enim velit mattis orci. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Proin hendrerit sit amet purus et viverra. Morbi malesuada, libero nec lacinia auctor, erat sapien pharetra libero, nec eleifend enim felis et metus. Nulla hendrerit magna tortor, sit amet fermentum metus vestibulum sed. Morbi faucibus enim id tristique scelerisque. Quisque porta mi a porta imperdiet. Cras gravida mollis velit, et tempor turpis elementum mattis. Vivamus dictum id justo sit amet laoreet. Mauris interdum dolor a mi ullamcorper pellentesque. Aliquam nunc sapien, viverra vel orci non, consequat pellentesque mauris. Phasellus convallis consectetur eros, eu lobortis justo. Praesent massa erat, interdum eget mi in, dictum viverra augue. Cras ultrices felis at sollicitudin scelerisque.
                    
                    Phasellus mattis lacus nec rhoncus dapibus. Nunc aliquam porttitor magna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Integer congue felis quis ligula placerat ultricies. Vivamus neque lorem, pulvinar sed velit sed, dignissim blandit dui. Aliquam vitae ullamcorper velit. Praesent enim arcu, interdum eu risus a, sodales scelerisque magna. Suspendisse vestibulum sollicitudin augue nec auctor. Maecenas venenatis, sem eu vestibulum dignissim, dui lectus condimentum ex, ut pretium erat eros nec dui. Duis eget purus ac ante ultrices posuere. Etiam porttitor enim eu nunc consequat pretium. Integer scelerisque bibendum lectus, ac laoreet felis venenatis sed. Integer sit amet tortor at nisi convallis pharetra. Etiam a ante pulvinar, congue ipsum sed, faucibus elit. Nullam feugiat, velit eget mattis congue, sem ipsum eleifend dui, at efficitur nisi dui quis ex. Duis lacus purus, volutpat vitae bibendum a, ultricies sit amet lectus.
                    """
