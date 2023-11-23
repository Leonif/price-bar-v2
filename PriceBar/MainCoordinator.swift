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
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    @MainActor 
    func start() {
        let mainViewModel = MainViewModel(modelContext: createModelContext())
        let mainView = MainView(viewModel: mainViewModel)
        
        self.mainViewModel = mainViewModel

        let vc = UIHostingController(rootView: mainView)
        vc.navigationItem.title = "Сканер продуктов"

        self.mainViewModel?.scanButtonTapSubject.sink { [weak self] in
            self?.showScanScreen()
        }.store(in: &cancellables)
        
        navigationController.setViewControllers([vc], animated: true)
    }
    
    @MainActor 
    private func createModelContext() -> ModelContext  {
        return try! ModelContainer(for: Product.self, Pricing.self).mainContext
    }
    
    private func showScanScreen() {
        let vm = BarcodeScannerViewModel()
        let vc = BarcodeScannerViewController(viewModel: vm)
        vm.completedSubject.sink { [weak self] barcode in
            self?.mainViewModel?.barcodeScannedSubject.send(barcode)
            self?.navigationController.popViewController(animated: true)
        }.store(in: &cancellables)
        
        navigationController.pushViewController(vc, animated: true)
    }
}
