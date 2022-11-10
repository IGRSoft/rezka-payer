//
//  ListItemView.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 21.10.2022.
//

import SwiftUI

struct ListItemView: View {
        
    @Binding var item: SubCategoryList
    
    var body: some View {
        Text(item.name)
    }
}
