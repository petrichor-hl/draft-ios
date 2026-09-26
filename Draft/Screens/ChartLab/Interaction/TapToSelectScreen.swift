//
//  TapToSelectScreen.swift
//  Draft
//
//  ĐỀ BÀI — chart số bước trong app Sức khoẻ: chạm vào một cột là hiện
//  nhãn "TỔNG / 30 bước / 23 thg 9, 08–09". Chạm đơn, không phải chạm
//  giữ.
//
//  Mà màn Toolbox/Garmin đã đo được: .chartXSelection trong List CHỈ ăn
//  khi chạm giữ rồi rê. Chạm nhanh không ăn, vì chạm-rồi-kéo vốn thuộc về
//  cử chỉ cuộn của List, phải giữ một nhịp nó mới nhường.
//
//  Đã thử bắt tap bằng chartOverlay: chạm đơn ăn, nhưng lớp phủ nuốt luôn
//  cử chỉ chạm giữ rồi rê của .chartXSelection. Cách này đã được bỏ.
//
//  HAI CHART còn lại để so sánh cách xử lý cử chỉ:
//
//    A  chỉ .chartXSelection
//    B  .chartXSelection cộng tap và giữ-rê trong chartGesture
//
//  CẦN ĐO: chartGesture của B có nhận cả chạm đơn lẫn giữ-rê mà vẫn cho
//  List cuộn khi vuốt dọc nhanh hay không.
//

import Charts
import SwiftUI

private let day = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 23))!

private struct HourSteps: Identifiable {
  let id = UUID()
  let hour: Date
  let steps: Int
}

/// Một ngày, mỗi giờ một tổng. Phần lớn bằng 0 — người ta không đi bộ
/// liên tục — và vài cột vọt lên, đúng dáng chart trong app Sức khoẻ.
private let hourly: [HourSteps] = {
  let calendar = Calendar.current
  let values = [
    0, 55, 0, 0, 0, 0, 0, 60,
    30, 150, 8, 0, 470, 60, 0, 0,
    200, 20, 18, 0, 0, 0, 0, 0,
  ]

  return values.enumerated().map { hour, steps in
    HourSteps(
      hour: calendar.date(byAdding: .hour, value: hour, to: day)!,
      steps: steps
    )
  }
}()

/// Giá trị chọn trên trục X là một Date BẤT KỲ, không phải mốc đầu cột.
/// Phải tự nắn về đầu giờ mới tra được đúng bucket và đặt RuleMark trúng
/// tâm cột.
private func hourBucket(_ date: Date?) -> Date? {
  guard let date else { return nil }
  return Calendar.current.dateInterval(of: .hour, for: date)?.start
}

private func steps(at bucket: Date) -> Int {
  hourly.first { $0.hour == bucket }?.steps ?? 0
}

struct TapToSelectScreen: View {
  /// Charts vẽ nhãn trục theo locale của MÔI TRƯỜNG, còn Date.formatted()
  /// mặc định theo Locale.current của máy. App này có màn đổi ngôn ngữ nên
  /// hai thứ đó lệch nhau được — phải lấy locale ra rồi truyền vào format.
  @Environment(\.locale) private var locale

  @State private var selectedA: Date?
  @State private var selectedB: Date?

  var body: some View {
    List {
      Section {
        Chart {
          if let bucket = hourBucket(selectedA) {
            marker(at: bucket)
          }

          ForEach(hourly) { item in
            if item.steps > 0 {
              BarMark(
                x: .value("Giờ", item.hour, unit: .hour),
                y: .value("Bước", item.steps)
              )
              .foregroundStyle(.red)
            }
          }
        }
        .chartXSelection(value: $selectedA)
        .frame(height: 220)
        .padding(.top, 76)
      } header: {
        Text("A — chỉ .chartXSelection")
      } footer: {
        Text("Chạm rồi GIỮ một nhịp, sau đó rê ngang: lúc này chắc chắn ăn, đó là cử chỉ mà chartXSelection sinh ra để phục vụ.")
      }

      Section {
        Chart {
          if let bucket = hourBucket(selectedB) {
            marker(at: bucket)
          }

          ForEach(hourly) { item in
            if item.steps > 0 {
              BarMark(
                x: .value("Giờ", item.hour, unit: .hour),
                y: .value("Bước", item.steps)
              )
              .foregroundStyle(.red)
            }
          }
        }
        .chartXSelection(value: $selectedB)
        .chartGesture { proxy in
          let tap = SpatialTapGesture()
            .onEnded { proxy.selectXValue(at: $0.location.x) }
          let scrub = LongPressGesture(minimumDuration: 0.2)
            .sequenced(before: DragGesture(minimumDistance: 0))
            .onChanged { value in
              if case let .second(true, drag?) = value {
                proxy.selectXValue(at: drag.location.x)
              }
            }
          return tap.simultaneously(with: scrub)
        }
        .frame(height: 220)
        .padding(.top, 76)
      } header: {
        Text("B — tap và giữ-rê trong chartGesture")
      } footer: {
        Text("Chạm một lần để chọn ngay; giữ rồi rê ngang để đổi cột. Thử vuốt dọc nhanh trên chart để kiểm tra List còn cuộn được không.")
      }
    }
    .navigationTitle("Chạm chọn cột")
    .navigationBarTitleDisplayMode(.inline)
  }

  private func marker(at startOfHour: Date) -> some ChartContent {
    RuleMark(x: .value("Chọn", startOfHour.addingTimeInterval(1800)))
      .foregroundStyle(.gray.opacity(0.4))
      .annotation(
        position: .top,
        overflowResolution: .init(x: .fit, y: .disabled)
      ) {
        VStack(alignment: .leading, spacing: 1) {
          Text("TỔNG")
            .font(.caption2)
            .foregroundStyle(.secondary)

          HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text("\(steps(at: startOfHour))")
              .font(.title2.bold())
            Text("bước")
              .font(.callout)
              .foregroundStyle(.secondary)
          }

          Text(rangeLabel(startOfHour))
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
        .fixedSize()
      }
  }

  /// "23 thg 9, 08–09" — mốc đầu và mốc cuối của bucket, vì mỗi cột là
  /// TỔNG của cả giờ chứ không phải một phép đo.
  private func rangeLabel(_ bucket: Date) -> String {
    let calendar = Calendar.current
    let end = calendar.date(byAdding: .hour, value: 1, to: bucket)!
    let date = bucket.formatted(.dateTime.day().month(.abbreviated).locale(locale))
    let from = calendar.component(.hour, from: bucket)
    let to = calendar.component(.hour, from: end)
    return String(format: "%@, %02d–%02d", date, from, to)
  }
}

#Preview {
  NavigationStack {
    TapToSelectScreen()
  }
}
