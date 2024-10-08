//
//  SearchView.swift
//  PriceBar
//
//  Created by LEONID NIFANTIJEV on 17.02.2024.
//

import SwiftUI

struct SearchView: View {
    
    @StateObject var viewModel: SearchViewModel
    @State private var products: [Product] = []
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack {
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { // Использование .toolbar вместо .navigationBarItems для более гибкого управления
            ToolbarItem(placement: .principal) { // Размещение в центре навигационного бара
                HStack {
                    Image(systemName: "magnifyingglass") // Иконка поиска
                    TextField("Пошук", text: $viewModel.searchString)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .frame(maxWidth: .infinity) // Занимает всю доступную ширину
                        .focused($isFocused, equals: true)
                }
                .padding(.horizontal, 16)
            }
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
                    .foregroundColor(Color(ColorResource.black))
                
                Text(product.name)
                    .font(.system(size: 14, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color(ColorResource.black))
            }
        }
    }
}
