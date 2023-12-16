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
    let comment: String?
    
    enum CodingKeys: CodingKey {
        case date
        case barcode
        case price
        case comment
    }
}


@Model
class Pricing {
    let id = UUID().uuidString
    let date: Date
    let price: Double
    let comment: String?
    
    static let empty = Pricing(date: Date(), price: 0, comment: nil)
    
    @Relationship var product: Product?
    init(date: Date, price: Double, comment: String?) {
        self.date = date
        self.price = price
        self.product = nil
        self.comment = comment
    }
}
