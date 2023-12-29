//
//  History.swift
//  PriceBar
//
//  Created by LEONID NIFANTIJEV on 27.12.2023.
//

import SwiftData
import Foundation

@Model
class History {
    let id = UUID().uuidString
    
    init(date: Date, price: Double, comment: String?) {
    }
}
