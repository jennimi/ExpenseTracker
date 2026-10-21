//
//  SubCategory.swift
//  Kira
//
//  Created by Karyna Budi Sanjaya on 20/10/26.
//

import Foundation

enum CategoryKind: String, Codable {
    case need
    case want
}

struct SubCategory: Codable {
    let id: UUID
    let kind: CategoryKind
    let name: String
    let icon: String
}
