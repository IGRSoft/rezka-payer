//
//  CategoryList.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 21.10.2022.
//

import SwiftUI
import Foundation

struct CategoryList: Identifiable, Hashable, Equatable, Codable {
    static func == (lhs: CategoryList, rhs: CategoryList) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }
    
    var id = UUID()
    let type: Category
    let items: [SubCategoryList]?
    let name: String
    var iconName: String
}

protocol ListItemProtocol: Identifiable, Hashable, Codable {
    associatedtype ItemType
    var id: UUID { get }
    
    var name: String { set get }
    var uri: String { get set }
}

extension ListItemProtocol {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }
}

class SubCategoryList: ListItemProtocol, Identifiable {
    typealias ItemType = String
    
    var id = UUID()
    
    var name: String = ""
    var uri: String = ""
    
    init(name: String, uri: String) {
        self.name = name
        self.uri = uri
    }
    
    @ViewBuilder
    var detailsView: AnyView {
        AnyView(PreviewDetailView(item: self))
    }
}
