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
    
    var currentProduct: Product?
    
    let modelContext: ModelContext
    
    var scanButtonTapSubject = PassthroughSubject<Void, Never>()
    var newProductTapSubject = PassthroughSubject<Product, Never>()
    var newPriceTapSubject = PassthroughSubject<Double, Never>()
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
        products = modelContext.readFromDb()
        pricing = modelContext.readFromDb()
        
        addDefaultProducts()
        addDefaultPrices()
        
        cleanIfNeed()
        printNewComers()
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
    
    private func addDefaultPrices() {
        for index in products.indices {
            // add default prices
            let defaultPrices = cloudPricings.filter { $0.barcode == products[index].barcode }
            let dbPrices = products[index].pricings
            
            for priceItem in defaultPrices {
                if !dbPrices.contains(where: { $0.date == priceItem.date }) {
                    let candidate = Pricing(date: priceItem.date, price: priceItem.price)
                    candidate.product = products[index]
                    modelContext.insert(candidate)
                }
            }
        }
        saveModel()
    }
    
    private func printNewComers() {
        for cpd in products {
            if !cloudProducts.contains(where: { $0.barcode == cpd.barcode }) {
                debugPrint("==== New product comers ===== \(cpd.barcode), \(cpd.name)")
            }
        }
        
        
        for cps in pricing {
            if !cloudPricings.contains(where: { $0.price == cps.price  }) {
                cps.product.map { product in
                    debugPrint("==== New price comers ===== \(product.barcode), \(product.name) \(cps.date) \(cps.price)")
                }
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
                currentProduct = product
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
        
        newPriceTapSubject.sink { [weak self] price in
            guard let self else { return }
            
            let pricing = Pricing(date: .now, price: price)
            pricing.product = currentProduct
            
            modelContext.insert(pricing)
            saveModel()
            
            if let product = self.products.first(where: { $0.barcode == self.currentProduct?.barcode }) {
                
                product.pricePrint()
                
                
                self.currentProduct = product
                self.resultBarcodeScanning.send(.found(product))
            }
            
        }.store(in: &cancellables)
    }
    
    private func saveModel() {
        do {
            try modelContext.save()
            products = modelContext.readFromDb()
            pricing = modelContext.readFromDb()
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
