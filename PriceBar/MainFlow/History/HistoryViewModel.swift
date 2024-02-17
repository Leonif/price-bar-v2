//
//  HistoryViewModel.swift
//  PriceBar
//
//  Created by LEONID NIFANTIJEV on 27.12.2023.
//

import SwiftData
import SwiftUI
import Combine

protocol HistoryViewModelInterface: ObservableObject {
    var historyLoadedSubject: PassthroughSubject<[History], Never> { get }
    var historySelectedSubject: PassthroughSubject<History, Never> { get }
    
    func loadData()
}

@Observable
final class HistoryViewModel: HistoryViewModelInterface {
    
    let modelContext: ModelContext
    var historyLoadedSubject = PassthroughSubject<[History], Never>()
    var historySelectedSubject = PassthroughSubject<History, Never>()
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func loadData() {
        let history: [History] = modelContext.readFromDb()
        historyLoadedSubject.send(history)
    }
}

final class HistoryViewModelMock: HistoryViewModelInterface {
    var historyLoadedSubject = PassthroughSubject<[History], Never>()
    var historySelectedSubject = PassthroughSubject<History, Never>()
    
    func loadData() {
//        let history = [
//            History(date: Date(), product: .init(barcode: "4016369961599", name: "TEST1")),
//            History(date: Date(), product: .init(barcode: "4016369961599", name: "TEST2")),
//        ]
//        historyLoadedSubject.send(history)
    }
}
