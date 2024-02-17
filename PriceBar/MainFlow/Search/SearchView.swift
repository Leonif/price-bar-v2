//
//  SearchView.swift
//  PriceBar
//
//  Created by LEONID NIFANTIJEV on 17.02.2024.
//

import SwiftUI

struct SearchView<ViewModel>: View where ViewModel: SearchViewModelInterface {
    
    @ObservedObject var viewModel: ViewModel
    @State private var products: [Product] = []
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack {
            TextField("Пошук", text: $viewModel.searchString).padding(.horizontal, 16)
                .focused($isFocused, equals: true)
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    let list = Array(products.prefix(50)).sorted(by: { $0.barcode > $1.barcode })
                    ForEach(list, id: \.id) { product in
                        Button {
                            viewModel.productSelectedSubject.send(product)
                        } label: {
                            ProductItemView(product: product)
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 16)
                
            }
        }
        .onAppear {
            isFocused = true
        }
        .onReceive(viewModel.productLoadedSubject) { products in
            self.products = products
        }
    }
}


struct ProductItemView: View {
    var product: Product
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text(product.barcode)
                    .font(.system(size: 14, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                
                Text(product.name)
                    .font(.system(size: 14, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.black)
            }
        }
    }
}
