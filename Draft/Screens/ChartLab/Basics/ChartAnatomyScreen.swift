//
//  ChartAnatomyScreen.swift
//  Draft
//
//  Created by Lam Tran  on 24/9/26.
//

import Charts
import SwiftUI

struct DailySteps: Identifiable {
  let id = UUID()
  let day: String
  let steps: Int
}

private let week: [DailySteps] = [
  .init(day: "T2", steps: 6200),
  .init(day: "T3", steps: 8100),
  .init(day: "T4", steps: 4300),
  .init(day: "T5", steps: 9500),
  .init(day: "T6", steps: 7200),
]

struct ChartAnatomyScreen: View {
  var body: some View {
    List {
      Section {
        Chart(week) { item in
          BarMark(
            x: .value("Thứ", item.day),
            y: .value("Bước", item.steps)
          )
        }
        .frame(height: 240)
      } header: {
        Text("BarMark")
      } footer: {
        Text("Không có modifier nào. Trục, khoảng cách, màu, chiều cao cột — Charts tự quyết hết.")
      }
      
      Section {
        Chart(week) { item in
          BarMark(
            x: .value("Bước", item.steps),
            y: .value("Thứ", item.day)
          )
        }
        .frame(height: 240)
      }
      
      Divider()
      
      Section {
        Chart(week) { item in
          LineMark(
            x: .value("Thứ", item.day),
            y: .value("Bước", item.steps)
          )
        }
        .frame(height: 240)
      } header: {
        Text("LineMark")
      }
      
      Divider()
      
      Section {
        Chart(week) { item in
          PointMark(
            x: .value("Thứ", item.day),
            y: .value("Bước", item.steps)
          )
        }
        .frame(height: 240)
      } header: {
        Text("PointMark")
      }
    }
    .navigationTitle("Giải phẫu một Chart")
  }
}
