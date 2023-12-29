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
    @Binding var newComment: String

    let info: MainViewModel.ScannedInfo
    let product: CloudProduct
    
    var newPriceTapSubject: ((Double, String) -> Void)
    
    var body: some View {
            HStack {
                VStack {
                    TextField("Введите цену", text: $newPrice)
                        .font(.system(size: 20, weight: .semibold))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 8)
                        .frame(height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(.blue)
                        .keyboardType(.decimalPad)
                    
                    TextField("Комментарий", text: $newComment)
                        .font(.system(size: 20, weight: .semibold))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 8)
                        .frame(height: 40)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black, lineWidth: 1))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.blue)
                        .foregroundColor(.blue)
                }
                .padding(.leading, 8)
                .padding(.top, 8)
                .padding(.bottom, 8)
                
                if !info.isNew {
                    var priceButtonEnabled : Bool {
                        return newPrice != ""
                    }
                    
                    Button {
                        newPriceTapSubject(newPrice.double, newComment)
                        newPrice = ""
                        newComment = ""
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

#Preview {
    PriceInputView(newPrice: .constant(""), newComment: .constant(""), info: .idle, product: .mock, newPriceTapSubject: {_,_ in })
}
