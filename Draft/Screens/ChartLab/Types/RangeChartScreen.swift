//
//  RangeChartScreen.swift
//  Draft
//
//  ĐỀ BÀI — mọi mark từ đầu lab tới giờ nhận MỘT giá trị cho mỗi trục.
//  BarMark(x:y:) nghĩa là "ở x, một thanh từ ĐƯỜNG GỐC lên tới y". Chữ
//  đường gốc đó chưa bao giờ được viết ra, nhưng nó có thật: thanh luôn
//  mọc từ 0.
//
//  Range mark nhận HAI giá trị trên cùng một trục:
//
//    BarMark(x:yStart:yEnd:)    thanh dọc, nổi, không chạm đường gốc
//    BarMark(xStart:xEnd:y:)    thanh ngang, nổi -> Gantt
//    RectangleMark(...)         cùng hình nhưng không có logic bề rộng
//    AreaMark(x:yStart:yEnd:)   dải liên tục min–max (để dành màn #6)
//
//  CÂU HỎI của màn này: thanh thường BẮT BUỘC có 0 trong miền, không thì
//  nó bị cắt và nói dối về độ dài của chính mình. Thanh nổi thì không cần
//  0. Swift Charts có biết phân biệt hai trường hợp đó không?
//
//  Màn probe trước đây đã đo: mark nào cũng kéo trục số về chứa 0, bất kể
//  Bar, Line, Point hay Area. Nhưng đó đều là mark MỘT giá trị.
//
//  THƯỜNG THẤY Ở ĐÂU:
//    - dự báo 10 ngày trong app Thời tiết: mỗi ngày một capsule ngang từ
//      nhiệt độ thấp tới cao, cả cột chung một thang. Section B dựng lại
//    - nến chứng khoán: hai range mark cùng một x, thanh mảnh cho khoảng
//      cao–thấp (râu), thanh dày cho mở–đóng (thân). Khác nhau mỗi width:
//    - Gantt, lịch bay, ca trực: việc chạy từ mốc này tới mốc kia
//    - huyết áp: mỗi lần đo một thanh tâm trương – tâm thu
//    - khoảng tin cậy: PointMark cho giá trị đo, thanh mảnh cho sai số
//
//  Điểm chung: range mark hợp khi một hàng dữ liệu VỐN ĐÃ có hai đầu,
//  không phải khi ta gộp nhiều điểm rồi tính min/max.
//
//  ĐÃ ĐO trên simulator.
//
//  TRỤC Y VẪN CHỨA 0. Section A có dữ liệu nằm gọn trong 57–148 mà trục
//  vẫn chạy từ 0 lên 150. Swift Charts KHÔNG phân biệt thanh neo với thanh
//  nổi: hễ là mark số thì kéo miền về 0.
//
//  Với thanh thường thì đó là điều đúng — cắt mất đường gốc là thanh nói
//  dối về độ dài của chính nó. Với thanh nổi thì chỉ là phí: hơn nửa khung
//  bỏ trống, mọi khoảng bị ép vào một dải hẹp trên đỉnh. Nên range chart
//  gần như luôn phải tự đặt chartYScale, khác hẳn mark một giá trị.
//
//  .clipShape(Capsule()) DÙNG ĐƯỢC trên ChartContent, không chỉ trên View.
//
//  CHỒNG HAI .annotation trên cùng một mark thì cả hai đều hiện. Section B
//  dùng .leading cho số thấp và .trailing cho số cao, đúng bố cục một dòng
//  dự báo thời tiết.
//
//  AxisValueLabel(centered: true) — mốc của band scale nằm ở MÉP dải, nên
//  nhãn mặc định trôi lên trên thanh chứ không ngang hàng. Gạch đầu tiên
//  trong danh sách TODO ở Basics #5 được dùng thật.
//

import Charts
import SwiftUI

private let day = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 23))!

private struct HourRange: Identifiable {
  let id = UUID()
  let hour: Date
  let low: Int
  let high: Int
}

/// Tám giờ, mỗi giờ một khoảng nhịp tim thấp nhất – cao nhất.
/// Buổi sáng yên, giữa buổi có vận động, chiều hạ dần.
private let hourly: [HourRange] = {
  let calendar = Calendar.current
  let values: [(low: Int, high: Int)] = [
    (58, 72), (61, 84), (66, 121), (72, 148),
    (64, 95), (60, 78), (59, 70), (57, 66),
  ]

  return values.enumerated().map { offset, value in
    HourRange(
      hour: calendar.date(byAdding: .hour, value: offset + 6, to: day)!,
      low: value.low,
      high: value.high
    )
  }
}()

private struct DayForecast: Identifiable {
  let id = UUID()
  let day: String
  let low: Int
  let high: Int
}

/// Dựng lại mục "Dự báo 10 ngày" của app Thời tiết: mỗi ngày một khoảng
/// nhiệt độ, tất cả chung một thang.
private let forecast: [DayForecast] = [
  DayForecast(day: "Hôm nay", low: 25, high: 33),
  DayForecast(day: "T6", low: 26, high: 34),
  DayForecast(day: "T7", low: 26, high: 35),
  DayForecast(day: "CN", low: 25, high: 32),
  DayForecast(day: "T2", low: 24, high: 29),
  DayForecast(day: "T3", low: 24, high: 30),
  DayForecast(day: "T4", low: 25, high: 31),
]

struct RangeChartScreen: View {
  var body: some View {
    List {
      Section {
        Chart(hourly) { item in
          BarMark(
            x: .value("Giờ", item.hour, unit: .hour),
            yStart: .value("Thấp nhất", item.low),
            yEnd: .value("Cao nhất", item.high)
          )
          .foregroundStyle(.pink)
        }
        .chartYAxis {
          AxisMarks(position: .leading)
        }
        .frame(height: 220)
      } header: {
        Text("A — BarMark(x:yStart:yEnd:) thanh nổi")
      } footer: {
        Text("Mỗi thanh mang đủ hai đầu, không chạm đường gốc nữa. Nhưng dữ liệu chỉ nằm trong 57–148 mà trục Y vẫn chạy từ 0: Swift Charts không phân biệt thanh neo với thanh nổi, hễ là mark số thì kéo miền về 0. Hậu quả là hơn nửa khung bỏ trống, mọi khoảng bị ép vào dải hẹp trên đỉnh — nên range chart gần như luôn phải tự đặt chartYScale.")
      }

      Section {
        Chart(forecast) { item in
          BarMark(
            xStart: .value("Thấp nhất", item.low),
            xEnd: .value("Cao nhất", item.high),
            y: .value("Ngày", item.day)
          )
          .foregroundStyle(.orange)
          .clipShape(Capsule())
          .annotation(position: .leading) {
            Text("\(item.low)°").font(.caption).foregroundStyle(.secondary)
          }
          .annotation(position: .trailing) {
            Text("\(item.high)°").font(.caption)
          }
        }
        .chartXScale(domain: 20...38)
        .chartYScale(domain: forecast.map(\.day))
        .chartYAxis {
          AxisMarks(position: .leading) {
            // Mốc của band scale nằm ở MÉP dải, nên nhãn mặc định trôi lên
            // trên thanh. centered: true kéo nhãn về tâm dải, ngang hàng
            // với thanh. Một gạch trong danh sách TODO ở Basics #5.
            AxisValueLabel(centered: true)
          }
        }
        .frame(height: 260)
      } header: {
        Text("B — BarMark(xStart:xEnd:y:) kiểu dự báo 10 ngày")
      } footer: {
        Text("Khoảng chuyển sang trục X, trục Y thành band scale tên thứ. Cả bảy thanh chung một thang 20–38° nên ngày lạnh nằm lệch trái, ngày nóng lệch phải — đó mới là thứ đáng nhìn, chứ không phải độ dài từng thanh. Thử đổi chartXScale thành 24...35 xem hình đọc khác đi thế nào.")
      }
    }
    .navigationTitle("Range")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    RangeChartScreen()
  }
}
