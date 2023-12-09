//
//  ScanButtonView.swift
//  PriceBar
//
//  Created by LEONID NIFANTIJEV on 03.12.2023.
//

import SwiftUI
import Utils

struct ScanButtonView: View {
    
    @Binding var newName: String
    @Binding var newPrice: String
    
    var scanButtonTap: (() -> Void)
    var newProductButtonTap: ((Product) -> Void)
    
    private let info: MainViewModel.ScannedInfo
    private let product: Product?
    
    init(info: MainViewModel.ScannedInfo, product: Product?, newName: Binding<String>, newPrice: Binding<String>, scanButtonTap:  @escaping (() -> Void), newProductButtonTap: @escaping ((Product) -> Void)) {
        self.info = info
        self.product = product
        _newName = newName
        _newPrice = newPrice
        self.scanButtonTap = scanButtonTap
        self.newProductButtonTap = newProductButtonTap
    }
    
    var body: some View {
        var mainButtonEnabled : Bool {
            switch info {
            case .new:
                return newName != "" && newPrice != ""
            default:
                return true
            }
        }
        
        Button(action: {
            switch info {
            case .idle, .found:
                scanButtonTap()
            case let .new(barcode):
                let newProduct = Product(barcode: barcode, name: newName)
                newProduct.pricings.append(.init(date: .now, price: newPrice.double))
                newProductButtonTap(newProduct)
                
                newName = ""
                newPrice = ""
            }
        }) {
            var text: String {
                switch info {
                case .idle, .found:
                    return "Сканувати"
                case .new:
                    return "Добавить"
                }
            }
            
            Text(text)
                .frame(width: UIScreen.main.bounds.width - 32, height: 55)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(4)
        }
        .disabled(!mainButtonEnabled)
        .padding(.top, 16)
    }
}
