//
//  StocksScreen.swift
//  Draft
//
//  ĐỀ BÀI — dựng lại chart giá cổ phiếu trong app Chứng khoán của iPhone,
//  tab 1Y. Đó là area chart: LineMark nét sắc đặt trên AreaMark tô
//  gradient, nền tối, trục Y bên phải, miền khít dữ liệu.
//
//  Khác Garmin ở chỗ Garmin phải đổi màu theo giá trị nên buộc dùng
//  Canvas. Chart này một màu duy nhất, nên AreaMark thường là đủ — màn
//  Types #6 đã đo: cắt 0 khỏi miền không làm mất phần tô.
//
//  DỰNG TỪNG LỚP, mỗi chart thêm một thứ, để thấy cái nào đóng góp gì:
//
//    1  LineMark trần, không modifier nào — bản Charts tự quyết
//    2  đủ bộ: nền tối, miền khít, trục phải, gradient, line đè lên
//
//  ĐÃ ĐO trên simulator.
//
//  PHẦN LỚN "DÁNG STOCKS" NẰM Ở MIỀN, không ở màu. Chart 1 và chart 2 là
//  cùng một bộ số: chart 1 có 0 trong miền nên cả năm biến động co vào
//  một phần ba trên của khung, trông như đường gần phẳng; chart 2 lấy
//  đúng min…max nên nó trải hết chiều cao và mọi nhịp lên xuống hiện ra.
//  Gradient với nền tối chỉ là lớp sơn thêm vào sau.
//
//  NỀN TỐI CHO RIÊNG MỘT KHỐI làm bằng hai thứ đi cùng nhau:
//  listRowBackground cho cái thẻ, và .environment(\.colorScheme, .dark)
//  cho Chart. Cái thứ hai mới là mẹo: ép riêng khối đó sang chế độ tối
//  thì mọi màu ngữ nghĩa bên trong tự lật, nhãn trục thành sáng màu mà
//  không phải chỉ định foregroundStyle cho từng AxisValueLabel.
//
//  NHÃN TRỤC X NHÌN XUYÊN QUA ĐƯỢC vì gradient tắt gần hẳn ở đáy
//  (opacity 0.01). Đúng cơ chế đã đo ở Types #6: vùng tô tràn qua dải
//  nhãn và đè lên nó, tô đặc là mất trục. Ở đây ta lợi dụng điều đó thay
//  vì né nó.
//
//  DỮ LIỆU PHẢI TẤT ĐỊNH. Dùng Double.random trong mảng let thì mỗi lần
//  mở app chart lại khác, không đối chiếu với ảnh chụp được. Ở đây tự
//  viết một LCG với hằng số của Knuth, seed cố định.
//
//  CÒN LẠI: nhãn trục X hiện đang là "thg 11 2025" do Charts tự chọn,
//  bản thật chỉ ghi tên tháng và chỉ ghi năm ở chỗ giao năm — cần
//  AxisValueLabel dựng bằng ViewBuilder, đúng gạch còn nợ ở Basics #5.
//  Và volume chart bằng BarMark ở dưới, dùng chung trục thời gian.
//

import Charts
import SwiftUI

struct StockBar: Identifiable {
  let id = UUID()
  let day: Date
  let close: Double
  let volume: Double
}

/// Một năm giá đóng cửa, sinh bằng công thức tất định để mỗi lần mở app
/// đều ra đúng một hình — dùng Double.random thì chart nhảy mỗi lần chạy,
/// không đối chiếu được.
///
/// Nền là một đường đi lên, cộng hai sóng sin lệch chu kỳ cho có nhịp lên
/// xuống, cộng nhiễu từng phiên để có cái răng cưa đặc trưng của chart
/// tài chính. Nhiễu lấy từ một LCG tự viết, hằng số quen thuộc của Knuth.
private let bars: [StockBar] = {
  let calendar = Calendar.current
  let start = calendar.date(from: DateComponents(year: 2025, month: 9, day: 25))!
  let count = 252          // số phiên giao dịch của một năm

  var seed: UInt64 = 20_260_925
  func nextUnit() -> Double {
    seed = seed &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
    return Double(seed >> 33) / Double(1 << 31)
  }

  return (0..<count).map { index in
    let progress = Double(index) / Double(count - 1)
    let trend = 252 + 84 * progress
    let wave = 13 * sin(Double(index) / 27) + 7 * sin(Double(index) / 9.5)
    let noise = (nextUnit() - 0.5) * 6

    return StockBar(
      day: calendar.date(byAdding: .day, value: index, to: start)!,
      close: trend + wave + noise,
      volume: 38 + nextUnit() * 34 + abs(wave) * 0.9
    )
  }
}()

/// Khít đúng dữ liệu, không nới thêm — app Chứng khoán cũng vậy, nhãn
/// trên cùng chính là đỉnh của kỳ.
private let priceDomain: ClosedRange<Double> = {
  let closes = bars.map(\.close)
  return closes.min()!...closes.max()!
}()

struct StocksScreen: View {
  var body: some View {
    List {
      Section {
        Chart(bars) { bar in
          LineMark(
            x: .value("Ngày", bar.day),
            y: .value("Giá", bar.close)
          )
        }
        .frame(height: 240)
      } header: {
        Text("1 — LineMark trần")
      } footer: {
        Text("Chưa modifier nào. Charts tự quyết hết: trục Y bên trái kéo về chứa 0, nên cả năm biến động từ 243 tới 345 bị dồn vào một phần ba trên của khung. Màu xanh mặc định, nền theo List. Đây là chỗ xuất phát.")
      }

      Section {
        Chart(bars) { bar in
          AreaMark(
            x: .value("Ngày", bar.day),
            y: .value("Giá", bar.close)
          )
          .foregroundStyle(
            .linearGradient(
              colors: [.green.opacity(0.35), .green.opacity(0.01)],
              startPoint: .top,
              endPoint: .bottom
            )
          )

          LineMark(
            x: .value("Ngày", bar.day),
            y: .value("Giá", bar.close)
          )
          .foregroundStyle(.green)
          .lineStyle(StrokeStyle(lineWidth: 1.5))
        }
        .chartYScale(domain: priceDomain)
        .chartYAxis {
          AxisMarks(position: .trailing, values: .automatic(desiredCount: 4)) {
            AxisGridLine()
            AxisValueLabel()
          }
        }
        .frame(height: 240)
        .environment(\.colorScheme, .dark)
      } header: {
        Text("2 — nền tối, miền khít, trục phải, gradient")
      } footer: {
        Text("Bốn thay đổi. chartYScale lấy đúng min…max nên đường giá trải hết chiều cao. Trục sang phải, bốn mốc thôi. AreaMark tô gradient tắt dần, LineMark đè lên lấy nét sắc — Swift Charts không có kiểu area có viền. Và nền tối làm bằng listRowBackground cộng environment(\\.colorScheme, .dark): ép riêng khối này sang chế độ tối thì mọi màu ngữ nghĩa trong đó tự lật, khỏi phải chỉ định màu chữ cho từng nhãn trục.")
      }
      .listRowBackground(Color(white: 0.11))
    }
    .navigationTitle("Stocks — Giá cổ phiếu")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    StocksScreen()
  }
}
