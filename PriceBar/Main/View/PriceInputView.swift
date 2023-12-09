//
//  PriceInputView.swift
//  PriceBar
//
//  Created by LEONID NIFANTIJEV on 01.12.2023.
//

import SwiftUI
import Utils

struct PriceInputView: View {
    
    private let info: MainViewModel.ScannedInfo
    private let product: Product?
    @Binding private var newPrice: String
    
    var newPriceTapSubject: ((Double) -> Void)
    
    init(info: MainViewModel.ScannedInfo, product: Product?, newPrice: Binding<String>, newPriceTapSubject: @escaping ((Double) -> Void)) {
        self.info = info
        self.product = product
        _newPrice = newPrice
        self.newPriceTapSubject = newPriceTapSubject
    }
    
    var body: some View {
        if product != nil {
            HStack {
                TextField("Введите цену", text: $newPrice)
                    .font(.system(size: 30, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.blue)
                    .keyboardType(.decimalPad)
                
                if !info.isNew {
                    var priceButtonEnabled : Bool {
                        return newPrice != ""
                    }
                    
                    Button {
                        newPriceTapSubject(newPrice.double)
                        newPrice = ""
                        hideKeyboard()
                    } label: {
                        Text("+")
                            .frame(width: 40, height: 40)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }.disabled(!priceButtonEnabled)
                }
            }
        }
    }
}
