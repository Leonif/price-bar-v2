//
//  Pricing.swift
//  PriceBar
//
//  Created by LEONID NIFANTIJEV on 04.12.2023.
//
import SwiftData
import Foundation

@Model
class Pricing {
    let id = UUID().uuidString
    let date: Date
    let price: String
    
    static let empty = Pricing(date: Date(), price: "...")
    
    @Relationship var product: Product?
    init(date: Date, price: String) {
        self.date = date
        self.price = price
        self.product = nil
    }
}
