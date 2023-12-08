//
//  MainViewModel.swift
//  PriceBar
//
//  Created by LEONID NIFANTIJEV on 18.06.2023.
//

import Combine
import SwiftUI
import SwiftData
import Utils

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
    
    var cloudProducts: [CloudProduct] = []
    var cloudPricings: [CloudPricing] = []
    
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        setupBinding()
        loadDefaultData()
    }
    
    private func loadDefaultData() {
        let productsData = readJsonFile(name: "products")!
        let pricingData = readJsonFile(name: "pricing")!
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
            cloudPricings = try decoder.decode([CloudPricing].self, from: pricingData)
            cloudProducts = try decoder.decode([CloudProduct].self, from: productsData)
        } catch let error {
            debugPrint(error)
        }
    }
    
    
    func loadData() {
        do {
            let fetchProductDescriptor = FetchDescriptor<Product>()
            let fetchPricingDescriptor = FetchDescriptor<Pricing>()
            
            products = try modelContext.fetch(fetchProductDescriptor)
            pricing = try modelContext.fetch(fetchPricingDescriptor)
            
            addDefaultProducts()
            
            cleanIfNeed()
            printNewComers()
//            printPricing()
            
        } catch let error {
            debugPrint(error)
        }
    }
    
    private func addDefaultProducts() {
        for cpd in cloudProducts {
            if let index = products.firstIndex(where: { $0.barcode == cpd.barcode }) {
                products[index].name = cpd.name // name corrections
            } else {
                let candidate = Product(barcode: cpd.barcode, name: cpd.name)
                modelContext.insert(candidate)
            }
        }
        
        saveModel()
    }
    
    private func printPricing() {
//        pricing.forEach { pricing in
//            guard let product = pricing.product else { return }
//            debugPrint("\(pricing.date) barcode: \(product.barcode) name: \(product.name) price: \(pricing.price)")
//        }
        
        products.forEach { pr in
            debugPrint("barcode: \(pr.barcode) name: \(pr.name)")
        }
    }
    
    private func printNewComers() {
        debugPrint("==== New comers =====")
        for cpd in products {
            if !cloudProducts.contains(where: { $0.barcode == cpd.barcode }) {
                debugPrint(cpd.barcode, cpd.name)
            }
        }
    }
    
    private func cleanIfNeed() {
        pricing.forEach { pricing in
            if pricing.price <= 0 {
                modelContext.delete(pricing)
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
            saveModel()
            loadData()
            if let product = pricing.product {
                self.resultBarcodeScanning.send(.found(product))
            }
        }.store(in: &cancellables)
    }
    
    private func saveModel() {
        do {
            try modelContext.save()
        } catch let error {
            debugPrint(error)
        }
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
