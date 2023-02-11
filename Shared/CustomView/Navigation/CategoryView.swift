//
//  CategoryView.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 21.10.2022.
//

import SwiftUI

struct CategoryView: View {
    
    let horizontalSizeClass: UserInterfaceSizeClass?
    var category: CategoryList?
    @Binding var selection: SubCategoryList?
    
    var body: some View {
        if let category = category {
            SizeClassAdaptiveView(sizeClass: horizontalSizeClass) {
                SubcategoryListView(items: category.items ?? [], selection: $selection, useSelection: true)
            } compact: {
                SubcategoryListView(items: category.items ?? [])
                    .navigationDestination(for: SubCategoryList.self) { item in
                        MediaContentView()
                            .environmentObject(MediaContentViewModel(category: category.type, subCategories: category.items))
                    }
            }
            .navigationTitle(LocalizedStringKey(category.name))
            .frame(minWidth: 128, idealWidth: 200)
        }
    }
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            let category = CategoryList(type: .general, items: [SubCategoryList(name: "preview", uri: "hello")], name: "preview", iconName: "sparkles.tv")
            CategoryView(horizontalSizeClass: .regular, category: category, selection: .constant(SubCategoryList(name: "preview", uri: "hello")))
        }
    }
}
