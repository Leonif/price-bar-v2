//
//  SearchViewModel.swift
//  PriceBar
//
//  Created by LEONID NIFANTIJEV on 17.02.2024.
//

import SwiftData
import SwiftUI
import Combine

protocol SearchViewModelInterface: ObservableObject {
    var productLoadedSubject: PassthroughSubject<[Product], Never> { get }
    var productSelectedSubject: PassthroughSubject<Product, Never> { get }
    
    
    var searchString: String { get set }
    
    func search(_: String)
    
}

@Observable
final class SearchViewModel: SearchViewModelInterface {
    
    let modelContext: ModelContext
    var productLoadedSubject = PassthroughSubject<[Product], Never>()
    var productSelectedSubject = PassthroughSubject<Product, Never>()
    var searchString: String = "" { didSet {
        search(searchString)
    }}
    
    let predicate = #Predicate<Product> { snippet in
        snippet.name == "Друзі, коханки і велика халепа - Метью Перрі"
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func search(_ searchString: String) {
        let predicate = #Predicate<Product> { snippet in
            if searchString.isEmpty {
                false
            } else {
                snippet.name.localizedStandardContains(searchString)
            }
        }
        
        
        let products: [Product] = modelContext.filterFromDb(predicate: predicate)
        productLoadedSubject.send(products)
    }
}
