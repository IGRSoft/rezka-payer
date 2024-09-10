//
//  MediaAPIResponse.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 18.08.2022.
//

import Foundation
import SwiftSoup

struct MediaRezkaAPIResponse: Decodable {
    let medias: [Media]
    
    init(from html: String) throws {
        let doc = try SwiftSoup.parse(html)
        let items = try doc.body()?.getElementById("main")?.getElementsByClass("b-content__inline_items").first?.getElementsByClass("b-content__inline_item")
        
        var medias: [Media] = []
        
        try items?.forEach({ item in
            let coverElement = try item.getElementsByClass("b-content__inline_item-cover").first
            let linkElement = try item.getElementsByClass("b-content__inline_item-link").first
            
            let aTag = try linkElement?.getElementsByTag("a").first
            
            let url = try aTag?.attr("href") ?? ""
            let title = try aTag?.text() ?? ""
            
            let desc = try linkElement?.getElementsByTag("div").last?.text() ?? ""
            
            var category: Category = .general
            var seriesInfo: String?
            if let _ = try coverElement?.getElementsByClass("series").last {
                seriesInfo = try coverElement?.getElementsByClass("info").last?.text() ?? nil
                category = .series
            } else if let _ = try coverElement?.getElementsByClass("films").last {
                category = .films
            } else if let _ = try coverElement?.getElementsByClass("cartoons").last {
                seriesInfo = try coverElement?.getElementsByClass("info").last?.text() ?? nil
                category = .cartoons
            } else if let _ = try coverElement?.getElementsByClass("animation").last {
                seriesInfo = try coverElement?.getElementsByClass("info").last?.text() ?? nil
                category = .animation
            }
            
            guard desc.isPropaganda() == false else {
                return
            }
            
            let img: String = (try coverElement?.getElementsByTag("img").first?.attr("src") ?? "")
            
            let media = Media(title: title, url: url, descriptionShort: desc, description: nil, coverUrl: img, seriesInfo: seriesInfo, category: category, quality: .p1080)
            
            medias.append(media)
        })
        
        self.medias = medias
    }
}
