//
//  MainViewModel.swift
//  PriceBar
//
//  Created by LEONID NIFANTIJEV on 18.06.2023.
//

import Combine
import SwiftUI
import SwiftData

@Observable
final class MainViewModel: ObservableObject {
 
    var products: [Product] = []
    var pricing: [Pricing] = []
    
    let modelContext: ModelContext
    
    var scanButtonTapSubject = PassthroughSubject<Void, Never>()
    var newProductTapSubject = PassthroughSubject<Product, Never>()
    var newPriceTapSubject = PassthroughSubject<Pricing, Never>()
    var barcodeScannedSubject = PassthroughSubject<String, Never>()
    var resultBarcodeScanning = PassthroughSubject<ScannedInfo, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    var fixArray: [Product] = [
        .init(barcode: "9786178120924", name: "Метью Перрі. Друзі, коханки і велика халепа"),
        .init(barcode: "9786176796541", name: "Бодо Шефер. Шлях до фінансової свободи")
    ]
    
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        setupBinding()
    }
    
    func loadData() {
        do {
            let fetchProductDescriptor = FetchDescriptor<Product>()
            let fetchPricingDescriptor = FetchDescriptor<Pricing>()
            
            products = try modelContext.fetch(fetchProductDescriptor)
            pricing = try modelContext.fetch(fetchPricingDescriptor)
            
            cleanIfNeed()
            fixProductsIfNeed()
            printPricing()
            
        } catch let error {
            debugPrint(error)
        }
    }
    
    private func printPricing() {
        pricing.forEach { pricing in
            guard let product = pricing.product else { return }
            debugPrint("\(pricing.date) barcode: \(product.barcode) name: \(product.name) price: \(pricing.price)")
        }
    }
    
    private func cleanIfNeed() {
        pricing.forEach { pricing in
            if pricing.price.isEmpty {
                modelContext.delete(pricing)
            }
        }
    }
    
    private func fixProductsIfNeed() {
        for (index, product) in products.enumerated() {
            if let pr = fixArray.first(where: { $0.barcode == product.barcode }) {
                products[index].name = pr.name
            }
        }
    }
    
    private func setupBinding() {
        barcodeScannedSubject.sink { [weak self] barcode in
            guard let self else { return }
            if let product = products.first(where: { $0.barcode == barcode }) {
                self.resultBarcodeScanning.send(.found(product))
            } else {
                self.resultBarcodeScanning.send(.new(barcode: barcode))
            }
        }.store(in: &cancellables)
        
        newProductTapSubject.sink { [weak self] newProduct in
            guard let self else { return }
            modelContext.insert(newProduct)
            do {
                try modelContext.save()
            } catch let error {
                debugPrint(error)
            }
            loadData()
            self.resultBarcodeScanning.send(.found(newProduct))
        }.store(in: &cancellables)
        
        newPriceTapSubject.sink { [weak self] pricing in
            guard let self else { return }
            modelContext.insert(pricing)
            do {
                try modelContext.save()
            } catch let error {
                debugPrint(error)
            }
            loadData()
            if let product = pricing.product {
                self.resultBarcodeScanning.send(.found(product))
            }
        }.store(in: &cancellables)
    }
}


extension MainViewModel {
    enum ScannedInfo {
        case idle
        case new(barcode: String)
        case found(Product)
        
        var isNew: Bool {
            switch self {
            case .new: return true
            default: return false
            }
        }
    }
}
