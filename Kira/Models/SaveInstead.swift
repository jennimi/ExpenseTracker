//
//  SaveInstead.swift
//  Kira
//
//  Created by Karyna Budi Sanjaya on 20/10/26.
//

import Foundation

struct SaveInstead: Codable {
    let id: UUID
    let title: String
    let amount: Int
    let date: Date
    let subcategory_id: UUID
    let created_at: Date
}
