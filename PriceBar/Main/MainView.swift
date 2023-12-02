//
//  MainView2.swift
//  PriceBar
//
//  Created by LEONID NIFANTIJEV on 24.06.2023.
//

import SwiftUI
import Combine

struct MainView: View {

    @ObservedObject var viewModel: MainViewModel

    @State private var info: MainViewModel.ScannedInfo
    @State private var product: Product?
    
    @State private var newName: String
    @State private var newPrice: String
        
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        _info = State<MainViewModel.ScannedInfo>(initialValue: .idle)
        _newName = State<String>(initialValue: "")
        _newPrice = State<String>(initialValue: "")
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ProductNameInputView(info: info, product: product, newName: $newName)
            
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
                    viewModel.scanButtonTapSubject.send()
                case let .new(barcode):
                    let newProduct = Product(barcode: barcode, name: newName)
                    newProduct.pricing.append(.init(date: .now, price: newPrice))
                    viewModel.newProductTapSubject.send(newProduct)
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
            
            PriceInputView(info: info, product: product, newPrice: $newPrice) { [weak viewModel] price in
                viewModel?.newPriceTapSubject.send(price)
            }

            PriceListView(product: $product)
        }
        .padding(16)
        .background(Color.white)
        .onAppear {
            self.viewModel.loadData()
        }
        .onReceive(viewModel.resultBarcodeScanning) { item in
            self.info = item
            switch item {
            case .idle:
                self.product = nil
            case let .found(product):
                self.product = nil
                self.product = product
            case let .new(barcode):
                self.product = .init(barcode: barcode, name: "")
            }
        }
        .onReceive(viewModel.scanButtonTapSubject) { _ in  }
    }
}


extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
