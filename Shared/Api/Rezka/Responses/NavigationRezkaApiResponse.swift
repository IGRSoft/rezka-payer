//
//  NavigationRezkaApiResponse.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 21.10.2022.
//

import Foundation
import SwiftSoup

struct NavigationRezkaApiResponse: Decodable {
    let categories: [CategoryList]
    
    init(from html: String) throws {
        let doc = try SwiftSoup.parse(html)
        let items = try doc.body()?.getElementById("topnav-menu")?.getElementsByClass("b-topnav__item")
        let filtersElement = try doc.body()?.getElementById("main")?.getElementsByClass("b-content__main_filters").first
        
        var categories: [CategoryList] = []
        
        try items?.forEach({ item in
            let titleElement = try item.getElementsByClass("b-topnav__item-link").first
            let subCategoriesElement = try item.getElementsByClass("b-topnav__sub").first
            
            let titleElementTag = try titleElement?.getElementsByTag("a").first
            
            let typeString = try titleElementTag?.attr("href") ?? ""
            let title = try titleElementTag?.text() ?? ""
            
            let mainSubCategories = try subCategoriesElement?.getElementsByClass("left").first?.getElementsByTag("li")
            let additionalSubCategories = try subCategoriesElement?.getElementsByClass("right").first?.getElementsByTag("li")
            let filterCategories = try filtersElement?.getElementsByClass("b-content__main_filters_item")
            
            var subCategories = [SubCategoryList]()
            
            try filterCategories?.forEach({ sub in
                let aTag = try sub.getElementsByTag("a")
                let title = try aTag.text()
                let uri = String(try aTag.attr("href").split(separator: "/").last ?? "")
                
                subCategories.append(SubCategoryList(name: title, uri: uri))
            })
            
            try mainSubCategories?.forEach({ sub in
                let aTag = try sub.getElementsByTag("a")
                let title = try aTag.text()
                let uri = String(try aTag.attr("href").split(separator: "/").last ?? "")
                
                subCategories.append(SubCategoryList(name: title, uri: uri))
            })
            
            try additionalSubCategories?.forEach({ sub in
                let aTag = try sub.getElementsByTag("a")
                let title = try aTag.text()
                let uri = try titleElementTag?.attr("href") ?? ""
                
                subCategories.append(SubCategoryList(name: title, uri: uri))
            })
            
            let type = Category(rawValue: typeString.letters) ?? .none
            assert(type != .none, "new category: \(typeString)")
            
            let categoryList = CategoryList(type: type, items: subCategories, name: title, iconName: "")
            
            categories.append(categoryList)
        })
        
        categories = categories.dropLast(2)
        let element = categories.remove(at: categories.count - 1)
        categories.insert(element, at: 0)
        
        let categoryList = CategoryList(type: .search, items: [], name: "", iconName: "magnifyingglass")
        categories.append(categoryList)
        
        self.categories = categories
    }
}
