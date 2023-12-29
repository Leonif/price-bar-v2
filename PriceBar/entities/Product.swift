//
//  Product.swift
//  PriceBar
//
//  Created by LEONID NIFANTIJEV on 04.12.2023.
//
import SwiftData
import Foundation

@Model
class Product {
    let barcode: String
    var name: String
    
    static let empty = Product(barcode: "...", name: "...")
    
    @Relationship var pricings: [Pricing]
    init(barcode: String, name: String) {
        self.barcode = barcode
        self.name = name
        self.pricings = []
    }
    
    func pricePrint() {
        pricings.forEach { pricing in
            print("\(barcode): price \(pricing.price)")
        }
    }
}


struct CloudProduct: Decodable {
    let barcode: String
    let name: String
    
    static let empty = CloudProduct(barcode: "...", name: "...")
    static let mock = CloudProduct(barcode: "4016369961599", name: "Lacalut")
}
