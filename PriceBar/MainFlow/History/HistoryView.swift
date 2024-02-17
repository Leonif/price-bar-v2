//
//  HistoryView.swift
//  PriceBar
//
//  Created by LEONID NIFANTIJEV on 27.12.2023.
//

import SwiftUI

struct HistoryView<ViewModel>: View where ViewModel: HistoryViewModelInterface {
    
    @ObservedObject var viewModel: ViewModel
    @State private var history: [History] = []
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                let list = Array(history.prefix(50)).sorted(by: { $0.date > $1.date })
                ForEach(list, id: \.id) { history in
                    Button {
                        viewModel.historySelectedSubject.send(history)
                    } label: {
                        HistoryItemView(history: history)
                    }
                }
                Spacer()
            }
            .padding(.vertical, 16)
           
        }
        .onAppear {
            viewModel.loadData()
        }
        .onReceive(viewModel.historyLoadedSubject) { history in
            self.history = history
        }
        .navigationTitle("Історія")
    }
}

#Preview {
    HistoryView(viewModel: HistoryViewModelMock())
}



struct HistoryItemView: View {
    var history: History
    
    var body: some View {
        VStack(alignment: .leading) {
            let date = history.date.formatted(.dateTime.day().month().year())
            Text(date)
                .font(.system(size: 14, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.blue)
            
            ProductItemView(product: history.product)
        }
    }
}
