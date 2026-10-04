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

enum City {
    case cupertino
    case sanFrancisco
}

struct Series: Identifiable {
    let city: String
    let sales: [SalesSummary]
    
    var id: String { city }
}

func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
    let components = DateComponents(year: year, month: month, day: day)
    return Calendar.current.date(from: components)!
}
