//
//  BarcodeScannerView.swift
//  PriceBar
//
//  Created by LEONID NIFANTIJEV on 18.06.2023.
//

import SwiftUI

struct BarcodeScannerView: View {
    
    @ObservedObject var viewModel: BarcodeScannerViewModel
    
    init(viewModel: BarcodeScannerViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Color.black.ignoresSafeArea()
    }
}
