//
//  CachingResourceLoaderDelegate.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 17.04.2025.
//  Copyright © 2025 IGR Soft. All rights reserved.
//

import AVKit

import AVFoundation

final class HLSCachingLoader: NSObject, AVAssetResourceLoaderDelegate {
    private let router: HLSURLRouter
    private let session: URLSession

    init(router: HLSURLRouter, cache: URLCache) {
        self.router = router
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = cache
        self.session = URLSession(configuration: config)
    }

    func resourceLoader(_ loader: AVAssetResourceLoader,
                        shouldWaitForLoadingOfRequestedResource request: AVAssetResourceLoadingRequest) -> Bool {
        guard let fakeURL = request.request.url,
              let realURL = router.resolve(fakeURL) else {
            request.finishLoading(with: NSError(domain: "HLSMapping", code: -1))
            return false
        }

        var urlRequest = URLRequest(url: realURL)
        urlRequest.cachePolicy = .returnCacheDataElseLoad

        session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                request.finishLoading(with: error)
                return
            }

            guard let data = data/*, let response,
                  let contentInfo = request.contentInformationRequest*/,
                  let dataRequest = request.dataRequest else {
                request.finishLoading(with: NSError(domain: "HLSData", code: -2))
                return
            }

//            contentInfo.contentType = response.mimeType
//            contentInfo.contentLength = Int64(data.count)
//            contentInfo.isByteRangeAccessSupported = true

            dataRequest.respond(with: data)
            request.finishLoading()
        }.resume()

        return true
    }
}

final class HLSURLRouter {
    private var mapping: [URL: URL] = [:]
    
    let cache: URLCache
    
    init(cache: URLCache) {
        self.cache = cache
    }

    /// Register a real URL and return a fake `caching://` URL for resource loading.
    func register(_ url: URL) -> URL {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.scheme = "caching"
        let fakeURL = components.url!
        mapping[fakeURL] = url
        return fakeURL
    }

    /// Resolve a fake `caching://` URL to the actual CDN URL.
    func resolve(_ fakeURL: URL) -> URL? {
        mapping[fakeURL]
    }
}
