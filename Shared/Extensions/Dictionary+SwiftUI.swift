//
//  Dictionary+SwiftUI.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 13.10.2022.
//

import SwiftUI
import OrderedCollections

fileprivate struct ArrayItem {
    var id = UUID()
    
    let text: String
}

extension ArrayItem: Identifiable, Hashable {}

extension OrderedDictionary {
    var grid: AnyView {
        let items: [ArrayItem] = self.keys.reduce(into: []) { partialResult, key in
            partialResult.append(contentsOf: [ArrayItem(text: "\(key)"), ArrayItem(text: "\(self[key]!)")])
        }
        
        let columns = [
            GridItem(.fixed(350)),
            GridItem(.flexible())
        ]
        
        return AnyView(VStack {
            VStack {
                NavigationView {
                    ScrollView {
                        LazyVGrid(columns: columns, alignment: .leading, spacing: 32) {
                            ForEach(Array(zip(items.indices, items)), id: \.0) { index, item in
                                if index % 2 == 1 {
                                    Button(action: {}) {
                                        Text(item.text)
                                    }
                                } else {
                                    Text(item.text)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        })
    }
}
