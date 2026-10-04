//
//  ShimmerSkeletonLab.swift
//  Draft
//

import SwiftUI

struct ShimmerSkeletonLab: View {
    var body: some View {
        List {
            textSection
            skeletonSection
            articleSection
        }
        .navigationTitle("Shimmer & Skeleton Lab")
    }

    private var textSection: some View {
        Section {
            Text("Swipe to Pay")
                .font(.system(size: 44, weight: .semibold))
                .shimmer(color: .red)
                .padding(.vertical, 16)

            Text("Đang chuẩn bị nội dung…")
                .font(.headline)
                .foregroundStyle(.indigo)
                .shimmer()
                .padding(.vertical, 8)

            Text("Đang chuẩn bị nội dung…")
                .font(.headline)
                .foregroundStyle(.indigo)
                .opacity(0.4)
                .shimmer(color: .red)
                .padding(.vertical, 8)
        } header: {
            Text("1. Text shimmer")
        } footer: {
            Text("Mask nằm riêng trong overlay: vệt màu chỉ hiện trong nét chữ, còn chữ gốc giữ nguyên opacity.")
        }
    }

    private var skeletonSection: some View {
        Section {
            Rectangle()
                .fill(Color(uiColor: .systemGray2))
                .frame(height: 120)
                .shimmer()
                .accessibilityLabel("Skeleton hình chữ nhật")

            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .systemGray2))
                .frame(height: 64)
                .shimmer()
                .accessibilityLabel("Skeleton bo góc")

            HStack(spacing: 14) {
                Circle()
                    .fill(Color(uiColor: .systemGray2))
                    .frame(width: 52, height: 52)

                VStack(alignment: .leading, spacing: 10) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(uiColor: .systemGray2))
                        .frame(height: 16)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(uiColor: .systemGray2))
                        .frame(maxWidth: 150)
                        .frame(height: 12)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .shimmer()
            .padding(.vertical, 8)
        } header: {
            Text("2. Skeleton shapes")
        } footer: {
            Text("Rectangle, RoundedRectangle và Circle dùng chung .shimmer(). Gắn modifier vào HStack để một vệt quét qua cả avatar lẫn các dòng chữ.")
        }
    }

    private var articleSection: some View {
        Section {
            LabArticleCard()
                .shimmer()
                .padding(.vertical, 8)
        } header: {
            Text("3. Article card shimmer")
        } footer: {
            Text("LabArticleCard().shimmer() áp dụng hiệu ứng lên cả thẻ. Những phần có nền cũng tham gia vào mask.")
        }
    }

}


struct LabArticleCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: "mountain.2.fill")
                .font(.system(size: 54))
                .foregroundStyle(.teal)
                .frame(maxWidth: .infinity)
                .frame(height: 140)
                .background(.teal.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))

            HStack {
                Text("Khám phá")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.teal)
                    .unredacted()
                Spacer()
                Text("5 phút đọc")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("Một ngày giữa núi rừng")
                .font(.title3.bold())
            Text("Chậm lại một chút để tận hưởng những điều nhỏ bé trên hành trình.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Label("Minh Anh", systemImage: "person.crop.circle.fill")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        ShimmerSkeletonLab()
    }
}
