//
//  DetailedMediaRezkaAPIResponse.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 12.10.2022.
//

import Foundation
import SwiftSoup
import OrderedCollections

struct DetailedMediaRezkaAPIResponse: Decodable {
    var detailedMedia: DetailedMedia
    
    init(from html: String) throws {
        let doc = try SwiftSoup.parse(html)
        let item = try doc.body()?.getElementById("main")?.getElementsByClass("b-content__main").first
        
        let mediaIdElement = try item?.getElementsByClass("b-userset__fav_holder").first
        let mediaId = try mediaIdElement?.attr("data-post_id") ?? "0"
        
        let title = try item?.getElementsByClass("b-post__title").first?.text() ?? ""
        let originalTitle = try item?.getElementsByClass("b-post__origtitle").first?.text() ?? ""
        
        var info: OrderedDictionary<String, String> = [:]
        let infoItems = try item?.getElementsByClass("b-post__info").first?.getElementsByTag("tr")
        try infoItems?.forEach({ infoLine in
            let items = try infoLine.getElementsByTag("td")
            if items.count == 2 {
                info[try items.first?.text() ?? ""] = try items.last?.text() ?? ""
            }
            else if let list = try infoLine.getElementsByClass("persons-list-holder").first {
                let spans = try list.getElementsByTag("span")
                let title = try spans.first?.text() ?? ""
                let index = title.index(title.startIndex, offsetBy: title.count)
                let persons = (try items.first?.text() ?? "")[index...]
                info[title] = String(persons)
            }
        })
        
        let defaultTranslation = info["В переводе:"] ?? ""
        
        let desc = try item?.getElementsByClass("b-post__description_text").last?.text() ?? ""
        
        let coverElement = try item?.getElementsByClass("b-sidecover").first
        
        let img = try coverElement?.getElementsByTag("img").first?.attr("src") ?? ""
        
        let translation = try DetailedMediaRezkaAPIResponse.translations(in: doc, default: defaultTranslation)
        
        detailedMedia = DetailedMedia(mediaId: Int(mediaId)!, title: title, titleOriginal: originalTitle, info: info, description: desc, translations: translation, seasons: [:], coverUrl: img)
    }
    
    private static func translations(in doc: Document, default translation: String) throws -> OrderedDictionary<Int, String> {
        var translations: OrderedDictionary<Int, String> = [:]
        
        let scripts = try doc.getElementsByTag("script")
        
        scripts.forEach { element in
            let script = element.data()
            
            for search in ["initCDNSeriesEvents", "initCDNMoviesEvents"] {
                if let pos = script.firstRange(of: search) {
                    let startIndex = script.index(pos.upperBound, offsetBy: 1)
                    let components = String(script[startIndex...]).split(separator: ", ")
                    if components.count > 1, let id = Int(components[1]) {
                        translations[id] = translation
                        break
                    }
                }
            }
        }
        
        let list = try doc.getElementsByClass("b-translators__list").first?.getElementsByTag("li")
        try list?.forEach({ translationElement in
            let title = try translationElement.attr("title")
            let id = Int(try translationElement.attr("data-translator_id")) ?? 0
            
            translations[id] = title
        })
        
        return translations
    }
}
