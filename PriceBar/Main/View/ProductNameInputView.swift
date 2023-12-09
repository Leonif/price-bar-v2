//
//  ProductNameInputView.swift
//  PriceBar
//
//  Created by LEONID NIFANTIJEV on 01.12.2023.
//

import SwiftUI

struct ProductNameInputView: View {
    
    @Binding var newName: String
    let info: MainViewModel.ScannedInfo
    let product: CloudProduct
    
    var body: some View {
        Text(product.barcode)
            .font(.system(size: 16, weight: .light))
            .multilineTextAlignment(.center)
            .foregroundColor(.black)
        
        switch info {
        case .idle, .found:
            Text(product.name)
                .font(.system(size: 25, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
        case .new:
            TextField("Введите название", text: $newName)
                .font(.system(size: 25, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(.green)
        }
    }
}
