//
//  HistoryView.swift
//  PriceBar
//
//  Created by LEONID NIFANTIJEV on 27.12.2023.
//

import SwiftUI

struct HistoryView<ViewModel>: View where ViewModel: HistoryViewModelInterface {
    
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    
    var body: some View {
        Text("Text")
    }
}

#Preview {
    HistoryView(viewModel: HistoryViewModelMock())
}



