//
//  HistoryViewModel.swift
//  PriceBar
//
//  Created by LEONID NIFANTIJEV on 27.12.2023.
//

import SwiftData
import SwiftUI

protocol HistoryViewModelInterface: ObservableObject {
    
}

@Observable
final class HistoryViewModel: HistoryViewModelInterface {
    
    let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        setupBinding()
        
    }
    
    private func setupBinding() {
    
    }
}

final class HistoryViewModelMock: HistoryViewModelInterface {}
