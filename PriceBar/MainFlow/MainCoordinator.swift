//
//  MainCoordinator.swift
//  PriceBar
//
//  Created by LEONID NIFANTIJEV on 18.06.2023.
//

import UIKit
import Combine
import SwiftUI
import SwiftData

final class MainCoordinator {
    private let navigationController: UINavigationController
    private var cancellables = Set<AnyCancellable>()
    private var mainViewModel: MainViewModel?
    private let modelContext: ModelContext
    
    init(navigationController: UINavigationController, modelContext: ModelContext) {
        self.navigationController = navigationController
        self.modelContext = modelContext
    }
    
    @MainActor 
    func start() {
        let viewModel = MainViewModel(modelContext: modelContext)
        let viewController = MainView(viewModel: viewModel).asViewController
        
        self.mainViewModel = viewModel
        self.mainViewModel?.scanButtonTapSubject.sink { [weak self] in
            self?.showScanScreen()
        }.store(in: &cancellables)
        
        self.mainViewModel?.showHistorySubject.sink { [weak self] in
            self?.showHistory()
        }.store(in: &cancellables)
        
        self.mainViewModel?.showSearchSubject.sink { [weak self] in
            self?.showSearch()
        }.store(in: &cancellables)
        
        navigationController.setViewControllers([viewController], animated: true)
    }
    
    private func showHistory() {
        let viewModel = HistoryViewModel(modelContext: modelContext)
        let viewController = HistoryView(viewModel: viewModel).asViewController
        viewModel.historySelectedSubject.sink { [weak self] history in
            guard let self else { return }
            self.navigationController.popViewController(animated: true)
            self.mainViewModel?.productSelectedSubject.send(history.product)
        }.store(in: &cancellables)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showSearch() {
        let viewModel = SearchViewModel(modelContext: modelContext)
        let viewController = SearchView(viewModel: viewModel).asViewController
        viewModel.productSelectedSubject.sink { [weak self] product in
            guard let self else { return }
            self.navigationController.popViewController(animated: true)
            self.mainViewModel?.productSelectedSubject.send(product)
        }.store(in: &cancellables)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showScanScreen() {
        let viewModel = BarcodeScannerViewModel()
        let viewController = BarcodeScannerViewController(viewModel: viewModel)
        viewModel.completedSubject.sink { [weak self] barcode in
            self?.mainViewModel?.barcodeScannedSubject.send(barcode)
            self?.navigationController.popViewController(animated: true)
        }.store(in: &cancellables)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
