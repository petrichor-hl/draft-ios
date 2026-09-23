//
//  Utils.swift
//  Draft
//
//  Created by Lam Tran  on 24/9/26.
//

import Foundation

struct SalesSummary: Identifiable {
  let weekday: Date
  let sales: Int
  
  var id: Date { weekday }
}

/// Dựng nhanh một `Date` từ năm/tháng/ngày theo lịch hiện hành.
func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
  Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? .now
}

enum City {
  case cupertino
  case sanFrancisco
}

struct Series: Identifiable {
  let city: String
  let sales: [SalesSummary]
  
  var id: String { city }
}
