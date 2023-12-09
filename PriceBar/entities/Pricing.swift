//
//  Pricing.swift
//  PriceBar
//
//  Created by LEONID NIFANTIJEV on 04.12.2023.
//
import SwiftData
import Foundation

struct CloudPricing: Decodable {
    
    let id = UUID().uuidString
    
    let date: Date
    let barcode: String
    let price: Double
    
    enum CodingKeys: CodingKey {
        case date
        case barcode
        case price
    }
}


@Model
class Pricing {
    let id = UUID().uuidString
    let date: Date
    let price: Double
    
    static let empty = Pricing(date: Date(), price: 0)
    
    @Relationship var product: Product?
    init(date: Date, price: Double) {
        self.date = date
        self.price = price
        self.product = nil
    }
}
