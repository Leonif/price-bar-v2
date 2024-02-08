//
//  MainView2.swift
//  PriceBar
//
//  Created by LEONID NIFANTIJEV on 24.06.2023.
//

import SwiftUI
import Combine
import SwiftData

struct MainView<ViewModel>: View where ViewModel: MainViewModelInterface {
    
    @ObservedObject var viewModel: ViewModel
    
    @State private var info: MainViewModel.ScannedInfo
    @State private var newName: String
    @State private var product: CloudProduct
    @State private var pricings: [CloudPricing]
    @State private var newPrice: String
    @State private var newComment: String
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        _info = State<MainViewModel.ScannedInfo>(initialValue: .idle)
        _newName = State<String>(initialValue: "")
        _newPrice = State<String>(initialValue: "")
        _newComment = State<String>(initialValue: "")
        _product = State<CloudProduct>(initialValue: viewModel.initialProduct)
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
                viewModel.newPriceTapSubject.send((newPrice.double, newComment))
            })
            
            if product.barcode != "..." {
                PriceInputView(newPrice:  $newPrice, newComment: $newComment, info: info, product: product) { price, comment in
                    viewModel.newPriceTapSubject.send((price, comment))
                }
                PriceListView(pricings: pricings)
            }
        }
        .navigationTitle("Сканер цін")
        .navigationBarItems(trailing: Button("Історія") {
            viewModel.showHistorySubject.send()
        })
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
                self.pricings = product.pricings.map { CloudPricing(date: $0.date, barcode: product.barcode, price: $0.price, comment: $0.comment)}
                self.newPrice = ""
                self.newComment = ""
            case let .new(barcode):
                self.product = .init(barcode: barcode, name: "")
                self.pricings = []
            }
        }
        .onReceive(viewModel.scanButtonTapSubject) { _ in  }
    }
}


#Preview {
    @MainActor
    func createModelContext() -> ModelContext  {
        return try! ModelContainer(for: Product.self, Pricing.self).mainContext
    }
    
    let mainViewModel = MainViewModelMock()
    return MainView(viewModel: mainViewModel)
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
