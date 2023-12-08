//
//  PriceListView.swift
//  PriceBar
//
//  Created by LEONID NIFANTIJEV on 01.12.2023.
//

import SwiftUI
import Utils

struct PriceListView: View {
    
    @Binding private var product: Product?
    
    init(product: Binding<Product?>) {
        _product = product
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            
            if let product {
                let list = Array(product.pricing.prefix(10)).sorted(by: { $0.date > $1.date })
                
                ForEach(list, id: \.id) { pricing in
                    HStack {
                        let date = pricing.date.formatted(.dateTime.day().month().year())
                        Text(date)
                            .font(.system(size: 14, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.blue)
                        
                        Text(":")
                            .font(.system(size: 14, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                        
                        Text(pricing.price.string)
                            .font(.system(size: 14, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.green)
                    }
                }
            }
        }
    }
}
