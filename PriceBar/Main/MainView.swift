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
            
            Text(product?.barcode ?? "...")
                .font(.system(size: 16, weight: .light))
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
            
            switch info {
            case .idle, .found:
                Text(product?.name ?? "...")
                    .font(.system(size: 25, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
            case .new:
                TextField("Введите название", text: $newName)
                    .font(.system(size: 25, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.green)
            }
            
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
                            let price = Pricing(date: .now, price: newPrice)
                            price.product = product
                            viewModel.newPriceTapSubject.send(price)
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
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(priceTitle(product: product), id: \.price) { (date, price) in
                    HStack {
                        Text(date)
                            .font(.system(size: 14, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.blue)
                        
                        Text(":")
                            .font(.system(size: 14, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                        
                        Text(price)
                            .font(.system(size: 14, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.green)
                    }
                }
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
    
    private func priceTitle(product: Product?) -> [(date: String, price: String)] {
        guard let product else { return [] }

        let pricing = Array(product.pricing.prefix(10))
        
        return pricing.map { price in
            let date = price.date.formatted(.dateTime.day().month().year())
            return (date, price.price)
        }
    }
}


extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
