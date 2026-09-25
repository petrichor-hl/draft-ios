//
//  AreaChartScreen.swift
//  Draft
//
//  ĐỀ BÀI — AreaMark: LineMark có tô phần dưới đường.
//    .foregroundStyle(LinearGradient)  gradient mờ dần xuống đáy
//    AreaMark(yStart:yEnd:)            dải giữa hai đường (min–max)
//    nhiều AreaMark cùng x             xếp chồng (stacked area)
//
//  Area luôn cần một mốc gốc để tô tới, nên nó nhạy với .chartYScale hơn
//  Line: cắt gốc trục thì phần tô cũng bị cắt theo.
//
//  Dữ liệu là giá đóng cửa 24 phiên, vì màn này dựng theo chart của app
//  Chứng khoán — chỗ area chart hay gặp nhất trên iPhone.
//
//  CÂU HỎI, và đây là câu đáng tiền nhất của màn:
//
//    AreaMark tô từ đường giá XUỐNG ĐƯỜNG GỐC. Mà mark số thì luôn kéo
//    miền về chứa 0 (đã đo ở màn Range). Với giá cổ phiếu 259–340, để 0
//    trong miền là ép toàn bộ biến động thành một vệt phẳng sát đỉnh.
//
//    Vậy khi chartYScale cắt 0 ra khỏi miền thì vùng tô đi đâu? Tô kín
//    xuống đáy khung, hay bị clip mất vì đường gốc không còn nằm trong
//    miền nữa? App Chứng khoán tô kín, nhưng không rõ nó được Charts cho
//    không hay phải tự dựng bằng AreaMark(yStart:yEnd:).
//
//  ĐÃ ĐO trên simulator.
//
//  TÔ KÍN XUỐNG ĐÁY. Cắt 0 khỏi miền không làm mất phần tô: chart B vẫn
//  đầy màu từ đường giá xuống hết khung. AreaMark không đòi đường gốc
//  phải nằm trong miền. Vậy chart app Chứng khoán dựng được bằng AreaMark
//  thường cộng chartYScale, không cần tới AreaMark(yStart:yEnd:).
//
//  NHƯNG VÙNG TÔ TRÀN QUA DẢI NHÃN TRỤC X VÀ ĐÈ LÊN NHÃN. Chart B mất
//  sạch nhãn ngày, trong khi chart A cùng dữ liệu vẫn còn đủ. Nhãn không
//  biến mất — chart C chứng minh: cùng miền 250–350, nhưng gradient nhạt
//  dần về đáy nên nhãn hiện xuyên qua lớp tô.
//
//  Đây mới là lý do thật của cái gradient trong app Chứng khoán. Không
//  phải để đẹp: tô đặc thì mất trục. Muốn giữ màu đặc thì phải chấp nhận
//  nhãn nằm chỗ khác.
//
//  KHÔNG CÓ KIỂU "AREA CÓ VIỀN". Phải vẽ hai mark trên cùng bộ dữ liệu,
//  AreaMark tô rồi LineMark đặt nét lên trên.
//
//  CÒN LẠI của màn này: stacked area, và bản clone hẳn chart AAPL với nền
//  tối, trục bên phải, volume chart ở dưới.
//

import Charts
import SwiftUI

private let firstDay = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 1))!

private struct DailyPrice: Identifiable {
  let id = UUID()
  let day: Date
  let close: Double
  let low: Double
  let high: Double
}

/// Hai tư phiên, xu hướng đi lên nhưng có mấy nhịp lún — cho giống biểu đồ
/// thật, đừng trơn quá. Biên độ trong phiên tính theo chỉ số nên vừa đều
/// đặn vừa không lặp lại.
private let prices: [DailyPrice] = {
  let calendar = Calendar.current
  let closes: [Double] = [
    268, 272, 265, 259, 263, 271, 278, 275,
    283, 291, 288, 296, 305, 299, 293, 302,
    314, 322, 317, 311, 325, 334, 330, 340,
  ]

  return closes.enumerated().map { index, close in
    let spread = 3 + Double((index * 7) % 9)
    return DailyPrice(
      day: calendar.date(byAdding: .day, value: index, to: firstDay)!,
      close: close,
      low: close - spread * 0.6,
      high: close + spread * 0.4
    )
  }
}()

struct AreaChartScreen: View {
  var body: some View {
    List {
      Section {
        Chart(prices) { item in
          AreaMark(
            x: .value("Ngày", item.day),
            y: .value("Giá", item.close)
          )
          .foregroundStyle(.green)
        }
        .frame(height: 220)
      } header: {
        Text("A — AreaMark(x:y:) trần")
      } footer: {
        Text("Giống hệt LineMark, chỉ thêm phần tô từ đường giá xuống ĐƯỜNG GỐC. Mà đường gốc là 0, nên miền trục Y bị kéo về 0 và cả dải giá 259–340 bẹp thành một vệt sát đỉnh. Biến động 30% trong hai tư phiên nhìn như đường thẳng.")
      }

      Section {
        Chart(prices) { item in
          AreaMark(
            x: .value("Ngày", item.day),
            y: .value("Giá", item.close)
          )
          .foregroundStyle(.green)
        }
        .chartYScale(domain: 250...350)
        .frame(height: 220)
      } header: {
        Text("B — chartYScale cắt 0 ra khỏi miền")
      } footer: {
        Text("Miền 250–350, biến động hiện ra đầy đủ, và phần tô vẫn kín xuống đáy — AreaMark không đòi đường gốc phải nằm trong miền. Nhưng so với chart A thì nhãn ngày ở trục X đâu mất rồi? Vùng tô tràn qua cả dải nhãn và đè lên. Chart C sẽ chứng minh nhãn vẫn còn nguyên ở đó.")
      }

      Section {
        Chart(prices) { item in
          AreaMark(
            x: .value("Ngày", item.day),
            y: .value("Giá", item.close)
          )
          .foregroundStyle(
            .linearGradient(
              colors: [.green.opacity(0.45), .green.opacity(0.02)],
              startPoint: .top,
              endPoint: .bottom
            )
          )

          LineMark(
            x: .value("Ngày", item.day),
            y: .value("Giá", item.close)
          )
          .foregroundStyle(.green)
        }
        .chartYScale(domain: 250...350)
        .chartYAxis {
          AxisMarks(position: .trailing)
        }
        .frame(height: 220)
      } header: {
        Text("C — gradient, và LineMark vẽ đè lên")
      } footer: {
        Text("Nhãn ngày hiện lại rồi — cùng miền như chart B, chỉ khác lớp tô nhạt dần nên nhìn xuyên qua được. Đó mới là lý do thật của cái gradient trong app Chứng khoán: tô đặc thì mất trục. Và Swift Charts không có kiểu \"area có viền\", phải vẽ HAI mark: AreaMark tô gradient rồi LineMark đặt nét sắc lên trên. Gradient ở đây an toàn vì chỉ một chuỗi — thêm chuỗi thứ hai là dính đúng bẫy bounding box ở Basics #4.")
      }

      Section {
        Chart(prices) { item in
          AreaMark(
            x: .value("Ngày", item.day),
            yStart: .value("Thấp nhất", item.low),
            yEnd: .value("Cao nhất", item.high)
          )
          .foregroundStyle(.green.opacity(0.25))

          LineMark(
            x: .value("Ngày", item.day),
            y: .value("Giá", item.close)
          )
          .foregroundStyle(.green)
        }
        .chartYScale(domain: 250...350)
        .chartYAxis {
          AxisMarks(position: .trailing)
        }
        .frame(height: 220)
      } header: {
        Text("D — AreaMark(x:yStart:yEnd:) dải thấp–cao")
      } footer: {
        Text("Hai đầu thay vì một, y như BarMark ở màn Range — nhưng liền mạch chứ không đứt thành từng thanh. Dải mờ là biên độ trong phiên, đường đậm là giá đóng cửa. Dùng khi x liên tục và ta muốn thấy cả mức lẫn độ không chắc chắn: khoảng tin cậy, dự báo, nhiệt độ ngày.")
      }
    }
    .navigationTitle("Area")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    AreaChartScreen()
  }
}
