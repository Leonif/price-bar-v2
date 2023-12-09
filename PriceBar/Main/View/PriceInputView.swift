//
//  PriceInputView.swift
//  PriceBar
//
//  Created by LEONID NIFANTIJEV on 01.12.2023.
//

import SwiftUI
import Utils

struct PriceInputView: View {
    
    @Binding var newPrice: String

    let info: MainViewModel.ScannedInfo
    let product: CloudProduct
    
    var newPriceTapSubject: ((Double) -> Void)
    
    var body: some View {
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
                        debugPrint("\(newPrice) \(newPrice.double)")
                        newPriceTapSubject(newPrice.double)
                        newPrice = ""
                        hideKeyboard()
                    } label: {
                        Text("+")
                            .frame(width: 40, height: 40)
                            .background(priceButtonEnabled ? Color.green : Color(UIColor(.green).withAlphaComponent(0.3)))
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }.disabled(!priceButtonEnabled)
                }
            }
        
    }
}
