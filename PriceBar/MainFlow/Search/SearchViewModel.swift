//
//  SearchViewModel.swift
//  PriceBar
//
//  Created by LEONID NIFANTIJEV on 17.02.2024.
//

import SwiftData
import SwiftUI
import Combine

final class SearchViewModel: ObservableObject {
    
    let modelContext: ModelContext
    var productLoadedSubject = PassthroughSubject<[Product], Never>()
    var productSelectedSubject = PassthroughSubject<Product, Never>()
    var searchString: String = "" { didSet {
        search(searchString)
    }}
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func search(_ searchString: String) {
        let predicate = #Predicate<Product> { snippet in
            if searchString.isEmpty {
                false
            } else {
                snippet.name.localizedStandardContains(searchString) ||
                snippet.barcode.localizedStandardContains(searchString)
            }
        }
        
        
        let products: [Product] = modelContext.filterFromDb(predicate: predicate)
        productLoadedSubject.send(products)
    }
}
