//
//  BackgroundRegionScreen.swift
//  Draft
//
//  ĐỀ BÀI — RectangleMark vẽ cả một VÙNG, dùng làm nền: dải giá trị mục
//  tiêu, vùng cảnh báo, zone. Nó không thuộc về điểm dữ liệu nào nên phải
//  viết ngoài ForEach — bắt buộc dùng dạng Chart { } thay vì Chart(data) { },
//  như đã gặp ở màn 3 section E.
//
//    RectangleMark(yStart:yEnd:)               dải ngang, trải suốt chiều rộng
//    RectangleMark(xStart:xEnd:yStart:yEnd:)   hình chữ nhật trong một khoảng
//
//  RuleMark — anh em của nó, vẽ ĐƯỜNG thay vì vùng — tách sang màn riêng.
//
//  ĐÃ ĐO — bốn section, năm ngày, cột cao nhất 9.500.
//
//  A / B — THỨ TỰ KHAI BÁO QUYẾT ĐỊNH LỚP. Cùng một đoạn code, đổi chỗ
//  RectangleMark với ForEach: viết trước thì vùng nằm dưới làm nền, viết
//  sau thì đè lên cột. Không có zIndex nào cả, thứ tự là tất cả.
//
//  D — RectangleMark ĂN VÀO DOMAIN như một mark thật. Vùng 15.000–20.000
//  kéo trục Y lên 20.000 và bóp toàn bộ cột xuống nửa dưới khung. Nên
//  dùng nó vẽ ngưỡng cao là tự phá biểu đồ của mình.
//
//  C — CÁI BẪY NẶNG NHẤT. RectangleMark(xStart:xEnd:) khai TRƯỚC ForEach
//  thì nó giới thiệu "T3" và "T5" với band scale trước tiên. Mà band scale
//  xếp category theo THỨ TỰ XUẤT HIỆN (đã đo ở màn 2), nên hai giá trị đó
//  chiếm hai dải đầu và trục thành T3 / T5 / T2 / T4 / T6.
//
//  Charts không sai — nó làm đúng luật đã biết. Nhưng khác hẳn ý định, và
//  nguy hiểm hơn A/B nhiều: A/B chỉ đổi lớp trên dưới, còn C đổi CÁCH ĐỌC
//  dữ liệu. Nhìn lướt sẽ tưởng T3 là ngày đầu tuần.
//
//  Chữa bằng chartXScale(domain: week.map(\.day)) — khoá thứ tự category
//  lại thì không mark nào chen được nữa. Đúng nguyên tắc từ màn 5: miền
//  quyết định, mark chỉ vẽ trong miền đó. Dùng map thay vì gõ tay mảng để
//  thêm ngày mới là miền tự cập nhật.
//
//  Chi tiết phụ: trên band scale, .value("Từ", "T3") trỏ tới TÂM của dải
//  chứ không phải mép, nên vùng cắt đôi cột T3 và T5 theo chiều dọc.
//

import Charts
import SwiftUI

private let week: [DayStep] = [
  .init(day: "T2", steps: 6200),
  .init(day: "T3", steps: 8100),
  .init(day: "T4", steps: 4300),
  .init(day: "T5", steps: 9500),
  .init(day: "T6", steps: 7200),
]

struct BackgroundRegionScreen: View {
  var body: some View {
    List {
      Section {
        Chart {
          RectangleMark(
            yStart: .value("Từ", 7000),
            yEnd: .value("Đến", 9000)
          )
          .foregroundStyle(.green.opacity(0.15))

          ForEach(week) { item in
            BarMark(
              x: .value("Thứ", item.day),
              y: .value("Bước", item.steps)
            )
          }
        }
        .frame(height: 240)
      } header: {
        Text("A — vùng nền vẽ TRƯỚC")
      } footer: {
        Text("Không khai x nên vùng trải suốt chiều rộng. Viết trước ForEach nên nằm DƯỚI các cột — đây là vùng mục tiêu 7.000–9.000 bước.")
      }

      Section {
        Chart {
          ForEach(week) { item in
            BarMark(
              x: .value("Thứ", item.day),
              y: .value("Bước", item.steps)
            )
          }

          RectangleMark(
            yStart: .value("Từ", 7000),
            yEnd: .value("Đến", 9000)
          )
          .foregroundStyle(.green)
        }
        .frame(height: 240)
      } header: {
        Text("B — vùng nền vẽ SAU")
      } footer: {
        Text("Y hệt A, chỉ đổi thứ tự hai khối. Charts vẽ theo thứ tự khai báo nên vùng giờ ĐÈ LÊN cột. Không có zIndex nào cả.")
      }

      Section {
        Chart {
          RectangleMark(
            xStart: .value("Từ", "T3"),
            xEnd: .value("Đến", "T5"),
            yStart: .value("Từ", 0),
            yEnd: .value("Đến", 10000)
          )
          .foregroundStyle(.orange.opacity(0.15))

          ForEach(week) { item in
            BarMark(
              x: .value("Thứ", item.day),
              y: .value("Bước", item.steps)
            )
          }
        }
        .chartXScale(domain: week.map(\.day))
        .frame(height: 240)
      } header: {
        Text("C — vùng giới hạn theo trục X")
      } footer: {
        Text("Khai cả xStart/xEnd thì vùng co lại thành hình chữ nhật. BẮT BUỘC có chartXScale: thiếu nó thì RectangleMark giới thiệu T3 và T5 trước ForEach, band scale xếp chúng vào hai dải đầu và thứ tự thành T3/T5/T2/T4/T6.")
      }

      Section {
        Chart {
          RectangleMark(
            yStart: .value("Từ", 15000),
            yEnd: .value("Đến", 20000)
          )
          .foregroundStyle(.red.opacity(0.15))

          ForEach(week) { item in
            BarMark(
              x: .value("Thứ", item.day),
              y: .value("Bước", item.steps)
            )
          }
        }
        .frame(height: 240)
      } header: {
        Text("D — vùng nằm ngoài tầm dữ liệu")
      } footer: {
        Text("Vùng 15.000–20.000 trong khi cột cao nhất chỉ 9.500. Trục Y có nới lên để chứa vùng không? Nếu có thì RectangleMark được tính vào domain như một mark thật, và đặt ngưỡng lớn sẽ bóp bẹp biểu đồ.")
      }
    }
    .navigationTitle("Vùng nền")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    BackgroundRegionScreen()
  }
}
