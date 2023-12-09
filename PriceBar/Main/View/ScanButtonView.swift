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

    let info: MainViewModel.ScannedInfo
    let product: CloudProduct
    
    var scanButtonTap: (() -> Void)
    var newProductButtonTap: ((CloudProduct) -> Void)
    
    var body: some View {
        var mainButtonEnabled : Bool {
            switch info {
            case .new:
                return newName != ""
            default:
                return true
            }
        }
        
        Button(action: {
            switch info {
            case .idle, .found:
                scanButtonTap()
            case let .new(barcode):
                let newProduct = CloudProduct(barcode: barcode, name: newName)
                newProductButtonTap(newProduct)
                newName = ""
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
