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
    @State private var newName: String
    @State private var product: CloudProduct
    @State private var pricings: [CloudPricing]
    @State private var newPrice: String
        
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        _info = State<MainViewModel.ScannedInfo>(initialValue: .idle)
        _newName = State<String>(initialValue: "")
        _newPrice = State<String>(initialValue: "")
        _product = State<CloudProduct>(initialValue: .empty)
        _pricings = State<[CloudPricing]>(initialValue: [])
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ProductNameInputView(newName: $newName, info: info, product: product)

            ScanButtonView(newName: $newName, info: info, product: product, scanButtonTap: {
                viewModel.scanButtonTapSubject.send()
            }, newProductButtonTap: { newProduct in
                
                let product = Product(barcode: newProduct.barcode, name: newProduct.name)
                
                viewModel.newProductTapSubject.send(product)
                viewModel.newPriceTapSubject.send(newPrice.double)
            })
            
            if product.barcode != "..." {
                PriceInputView(newPrice:  $newPrice, info: info, product: product) { price in
                    viewModel.newPriceTapSubject.send(price)
                }
                PriceListView(pricings: pricings)
            }
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
                break
            case let .found(product):
                self.product = .init(barcode: product.barcode, name: product.name)
                self.pricings = product.pricings.map { CloudPricing(date: $0.date, barcode: product.barcode, price: $0.price)}
                self.newPrice = ""
            case let .new(barcode):
                self.product = .init(barcode: barcode, name: "")
                self.pricings = []
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
