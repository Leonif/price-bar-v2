//
//  BarcodeScannerViewModel.swift
//  PriceBar
//
//  Created by LEONID NIFANTIJEV on 18.06.2023.
//

import Combine

final class BarcodeScannerViewModel: ObservableObject {
   
    var completedSubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
}
