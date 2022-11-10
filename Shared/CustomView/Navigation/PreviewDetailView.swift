//
//  PreviewDetailView.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 21.10.2022.
//

import SwiftUI

struct PreviewDetailView: View {
    let item: SubCategoryList?
    
    var body: some View {
        VStack {
            if let item {
                Rectangle()
                    .fill(.red)
                    .frame(width: 200, height: 200)
                Text(item.name)
            } else {
                EmptyView()
            }
        }
        .navigationTitle(LocalizedStringKey(item?.name ?? ""))
    }
}


struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PreviewDetailView(item: SubCategoryList(name: "preview", uri: "hello"))
        }
        .previewLayout(.fixed(width: 768, height: 768))
    }
}

