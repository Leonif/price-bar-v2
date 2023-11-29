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
            
        } catch let error {
            debugPrint(error)
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

@Model
class Product {
    let barcode: String
    let name: String
    
    static let empty = Product(barcode: "...", name: "...")
    
    @Relationship var pricing: [Pricing]
    init(barcode: String, name: String) {
        self.barcode = barcode
        self.name = name
        self.pricing = []
    }
}

@Model
class Pricing {
    let id = UUID().uuidString
    let date: Date
    let price: String
    
    static let empty = Pricing(date: Date(), price: "...")
    
    @Relationship var product: Product?
    init(date: Date, price: String) {
        self.date = date
        self.price = price
        self.product = nil
    }
}
