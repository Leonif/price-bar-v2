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

protocol MainViewModelInterface: ObservableObject {
    
    var initialProduct: CloudProduct { get }
    
    var scanButtonTapSubject: PassthroughSubject<Void, Never> { get }
    var showHistorySubject: PassthroughSubject<Void, Never> { get }
    var showSearchSubject: PassthroughSubject<Void, Never> { get }
    var newProductTapSubject: PassthroughSubject<Product, Never> { get }
    var newPriceTapSubject: PassthroughSubject<(Double, String), Never> { get }
    var resultBarcodeScanning: PassthroughSubject<MainViewModel.ScannedInfo, Never> { get }
    
    func loadData()
}

@Observable
final class MainViewModel: MainViewModelInterface {
    var initialProduct = CloudProduct.empty

    var products: [Product] = []
    var pricing: [Pricing] = []
    
    var currentProduct: Product?
    
    let modelContext: ModelContext
    
    var scanButtonTapSubject = PassthroughSubject<Void, Never>()
    var showHistorySubject = PassthroughSubject<Void, Never>()
    var showSearchSubject = PassthroughSubject<Void, Never>()
    var newProductTapSubject = PassthroughSubject<Product, Never>()
    var newPriceTapSubject = PassthroughSubject<(Double, String), Never>()
    var barcodeScannedSubject = PassthroughSubject<String, Never>()
    var productSelectedSubject = PassthroughSubject<Product, Never>()
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
        guard products.isEmpty else { return }
        products = modelContext.readFromDb()
        pricing = modelContext.readFromDb()
        
        addDefaultProducts()
        addDefaultPrices()
        
        cleanIfNeed()
        Task.detached {
            self.printNewComers()
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
    
    private func addDefaultPrices() {
        for index in products.indices {
            // add default prices
            let defaultPrices = cloudPricings.filter { $0.barcode == products[index].barcode }
            let dbPrices = products[index].pricings
            
            for priceItem in defaultPrices {
                if !dbPrices.contains(where: { $0.date == priceItem.date }) {
                    let candidate = Pricing(date: priceItem.date, price: priceItem.price, comment: priceItem.comment)
                    candidate.product = products[index]
                    modelContext.insert(candidate)
                }
            }
        }
        saveModel()
    }
    
    private func printNewComers() {
        debugPrint("==== New product comers =====")
        for cpd in products {
            if !cloudProducts.contains(where: { $0.barcode == cpd.barcode }) {
                print("""
                {
                  "barcode": \"\(cpd.barcode)\",
                  "name": \"\(cpd.name)\"
                },
                """)
            }
        }
        
        debugPrint("==== New price comers ===== ")
        for cps in pricing {
            if !cloudPricings.contains(where: { $0.price == cps.price && $0.barcode == cps.product?.barcode }) {
                cps.product.map { product in
                    print("""
                          {
                            "date": \"\(cps.date)\",
                            "barcode": \"\(product.barcode)\",
                            "price": \(cps.price),
                            "comment": \"\(cps.comment ?? "")\"
                          },
                    """)
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
                updateHistory(product: product)
            } else {
                currentProduct = nil
                self.resultBarcodeScanning.send(.new(barcode: barcode))
            }
        }.store(in: &cancellables)
        
        productSelectedSubject.sink { [weak self] product in
            guard let self else { return }
            if let product = products.first(where: { $0.barcode == product.barcode }) {
                currentProduct = product
                self.resultBarcodeScanning.send(.found(product))
            }
        }.store(in: &cancellables)
        
        newProductTapSubject.sink { [weak self] newProduct in
            guard let self else { return }
            modelContext.insert(newProduct)
            currentProduct = newProduct
            do {
                try modelContext.save()
            } catch let error {
                debugPrint(error)
            }
            loadData()
            self.resultBarcodeScanning.send(.found(newProduct))
            self.updateHistory(product: newProduct)
        }.store(in: &cancellables)
        
        newPriceTapSubject.sink { [weak self] (price, comment) in
            guard let self else { return }
            
            let pricing = Pricing(date: .now, price: price, comment: comment)
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
    
    private func updateHistory(product: Product) {
        let history = History(date: Date(), product: product)
        modelContext.insert(history)
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


@Observable
final class MainViewModelMock: MainViewModelInterface {
    
    var initialProduct = CloudProduct.mock
    
    var scanButtonTapSubject = PassthroughSubject<Void, Never>()
    var showHistorySubject = PassthroughSubject<Void, Never>()
    var showSearchSubject = PassthroughSubject<Void, Never>()
    var newProductTapSubject = PassthroughSubject<Product, Never>()
    var newPriceTapSubject = PassthroughSubject<(Double, String), Never>()
    var resultBarcodeScanning = PassthroughSubject<MainViewModel.ScannedInfo, Never>()
    
    func loadData() {
       
    }
    
}
