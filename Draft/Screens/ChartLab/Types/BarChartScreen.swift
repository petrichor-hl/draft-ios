//
//  BarChartScreen.swift
//  Draft
//
//  ĐỀ BÀI — thanh ngang: BarMark(x: value, y: category). Đảo đúng hai
//  tham số so với ColumnChartScreen, không đổi gì khác.
//
//  Khi nào chọn ngang: nhãn category dài (tên món ăn, tên tỉnh) — để dọc
//  thì nhãn trục X không đủ chỗ. Số lượng hạng mục nhiều cũng hợp với
//  ngang vì cuộn dọc tự nhiên hơn cuộn ngang.
//
//  ĐÃ ĐO trên simulator.
//
//  NHÃN DÀI BỊ CẮT CỤT BẰNG DẤU BA CHẤM, không xoay nghiêng và cũng không
//  bị bỏ bớt. Chart A còn đủ sáu nhãn, nhưng ba trong số đó thành "Sức
//  kh…", "Hoá đ…", "Mua s…" — đủ để biết có sáu hạng mục, không đủ để
//  biết hạng mục nào. Đây mới là lý do thật để quay ngang, chứ không phải
//  vì đẹp hơn.
//
//  BAND SCALE XẾP DẢI THEO LẦN XUẤT HIỆN ĐẦU TIÊN TRONG MẢNG, không theo
//  alphabet và cũng không theo giá trị. Chart B ra đúng thứ tự mảng nguồn
//  đang để lộn xộn. Cùng một cơ chế với miền của scale màu ở màn Column.
//
//  Suy ra hai cách ra lệnh cho thứ tự, cả hai đều chạy: sort mảng nguồn,
//  hoặc nói thẳng chartYScale(domain:). Cách thứ hai rõ ý hơn — nhìn vào
//  chart là biết thứ tự do ai quyết — và không vỡ khi ai đó đổi cách nạp
//  dữ liệu ở tầng dưới.
//
//  NHÃN BAND MẶC ĐỊNH NẰM TRÊN THANH chứ không ngang hàng, vì mốc của
//  band ở mép dải. Ở đây trông lại hợp với bố cục bảng xếp hạng nên giữ
//  nguyên; muốn ngang hàng thì AxisValueLabel(centered: true), như màn
//  Range đã làm.
//

import Charts
import SwiftUI

private struct Spending: Identifiable {
  let id = UUID()
  let category: String
  /// Nghìn đồng.
  let amount: Int
}

/// Chi tiêu tháng 9. Cố ý để lộn xộn, không sắp theo số tiền cũng không
/// theo vần, để xem Charts tự xếp dải theo cái gì.
private let spending: [Spending] = [
  .init(category: "Đi lại", amount: 1_940),
  .init(category: "Ăn uống", amount: 4_850),
  .init(category: "Sức khoẻ", amount: 420),
  .init(category: "Hoá đơn & tiện ích", amount: 3_120),
  .init(category: "Giải trí", amount: 890),
  .init(category: "Mua sắm", amount: 1_560),
]

/// Thứ tự cho bảng xếp hạng: nhiều tiền nhất lên trên.
private let ranked = spending.sorted { $0.amount > $1.amount }.map(\.category)

struct BarChartScreen: View {
  var body: some View {
    List {
      Section {
        Chart(spending) { item in
          BarMark(
            x: .value("Hạng mục", item.category),
            y: .value("Chi tiêu", item.amount)
          )
          .foregroundStyle(.teal)
        }
        .frame(height: 260)
      } header: {
        Text("A — để dọc, đúng thứ không nên làm")
      } footer: {
        Text("Sáu hạng mục, nhãn dài nhất là \"Hoá đơn & tiện ích\". Trục X không đủ chỗ nên Charts cắt cụt bằng dấu ba chấm — không xoay nghiêng, cũng không bỏ bớt nhãn nào. Còn đủ sáu nhãn nhưng ba cái thành \"Sức kh…\", \"Hoá đ…\", \"Mua s…\": biết có sáu hạng mục, không biết hạng mục nào.")
      }

      Section {
        Chart(spending) { item in
          BarMark(
            x: .value("Chi tiêu", item.amount),
            y: .value("Hạng mục", item.category)
          )
          .foregroundStyle(.teal)
        }
        .frame(height: 260)
      } header: {
        Text("B — đảo hai tham số")
      } footer: {
        Text("Không thêm modifier nào, chỉ đổi chỗ x và y. Nhãn giờ nằm ngang, dài bao nhiêu cũng đọc được. Thứ tự các dải đúng y thứ tự mảng nguồn — band scale dựng miền theo LẦN XUẤT HIỆN ĐẦU TIÊN, không theo alphabet, không theo giá trị. Mà mảng đang lộn xộn, nên bảng này chưa xếp hạng được.")
      }

      Section {
        Chart(spending) { item in
          BarMark(
            x: .value("Chi tiêu", item.amount),
            y: .value("Hạng mục", item.category)
          )
          .foregroundStyle(.teal)
        }
        .chartYScale(domain: ranked)
        .frame(height: 260)
      } header: {
        Text("C — chartYScale(domain: đã sắp)")
      } footer: {
        Text("Sắp mảng rồi truyền danh sách tên vào domain. Vì miền dựng theo thứ tự gặp, sort thẳng mảng nguồn cũng ra kết quả y hệt — nhưng nói thẳng domain thì rõ ý hơn, nhìn chart là biết thứ tự do ai quyết, và không vỡ khi tầng dưới đổi cách nạp dữ liệu.")
      }

      Section {
        Chart(spending) { item in
          BarMark(
            x: .value("Chi tiêu", item.amount),
            y: .value("Hạng mục", item.category)
          )
          .foregroundStyle(.teal)
          .cornerRadius(4)
          .annotation(position: .trailing) {
            Text(item.amount.formatted())
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        }
        .chartYScale(domain: ranked)
        .chartXScale(domain: 0...5_600)
        .chartXAxis(.hidden)
        .frame(height: 260)
      } header: {
        Text("D — bỏ trục X, số đặt ở cuối thanh")
      } footer: {
        Text("Bảng xếp hạng không cần lưới: người ta đọc con số ở cuối thanh chứ không dóng lên trục. Ẩn trục X rồi gắn annotation .trailing là ra bố cục quen thuộc của Screen Time hay báo cáo chi tiêu. chartXScale phải tự đặt rộng hơn giá trị lớn nhất, nếu không nhãn của thanh dài nhất bị đẩy ra ngoài khung.")
      }
    }
    .navigationTitle("Bar ngang")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    BarChartScreen()
  }
}
