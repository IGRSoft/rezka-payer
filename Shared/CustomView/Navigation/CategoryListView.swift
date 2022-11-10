//
//  CategoryListView.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 21.10.2022.
//

import SwiftUI

struct CategoryListView: View {
    
    @State var item: CategoryList
    
    var body: some View {
        NavigationLink(value: item) {
            HStack {
                Image(systemName: item.iconName)
                    .font(.title)
                Text(LocalizedStringKey(item.name))
                    .font(.title)
                    .lineLimit(2)
            }
        }
    }
}
