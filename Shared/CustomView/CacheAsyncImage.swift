//
//  CacheAsyncImage.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 13.10.2022.
//

import SwiftUI

struct CacheAsyncImage<Content>: View where Content: View {
    
    private let url: URL
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> Content
    
    init(url: URL, scale: CGFloat = 1.0, transaction: Transaction = Transaction(), @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
    }
    
    var body: some View {
        if let cached = ImageCache[url] {
            //let _ = print("cached: \(url.absoluteString)")
            content(.success(cached))
        } else {
            //let _ = print("request: \(url.absoluteString)")
            AsyncImage(url: url, scale: scale, transaction: transaction) { phase in
                cacheAndRender(phase: phase)
            }
        }
    }
    
    func cacheAndRender(phase: AsyncImagePhase) -> some View {
        if case .success (let image) = phase {
            ImageCache[url] = image
        }
        
        return content(phase)
    }
}

extension AsyncImagePhase {
    var view: AnyView {
        switch self {
        case .empty:
            AnyView(HStack {
                Spacer()
                ProgressView()
                Spacer()
            })
            
        case .success(let image):
            AnyView(image
                .resizable()
                .aspectRatio(contentMode: .fit))
            
        case .failure:
            AnyView(HStack {
                Spacer()
                Image(systemName: "photo")
                    .imageScale(.large)
                Spacer()
            })
            
        @unknown default:
            fatalError()
        }
    }
}

fileprivate class ImageCache {
    static private var cache: [URL: Image] = [:]
    static subscript(url: URL) -> Image? {
        get {
            ImageCache.cache[url]
        }
        set {
            ImageCache.cache[url] = newValue
        }
    }
}
