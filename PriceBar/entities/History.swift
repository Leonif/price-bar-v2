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
    let date: Date
    @Relationship let product: Product
    
    init(date: Date, product: Product) {
        self.date = date
        self.product = product
    }
}
