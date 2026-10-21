//
//  MonthlyBudget.swift
//  Kira
//
//  Created by Karyna Budi Sanjaya on 20/10/26.
//

import Foundation

struct MonthlyBudget: Codable {
    let id: UUID
    let month: Date
    let total_amount: Int
    let needs_amount: Int
    let wants_amount: Int
}
