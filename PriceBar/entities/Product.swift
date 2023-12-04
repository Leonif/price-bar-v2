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
    
    @Relationship var pricing: [Pricing]
    init(barcode: String, name: String) {
        self.barcode = barcode
        self.name = name
        self.pricing = []
    }
}
