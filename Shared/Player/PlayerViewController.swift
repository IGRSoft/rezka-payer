//
//  PlayerViewController.swift
//  rezka-player
//
//  Created by vitalii on 01.11.2022.
//

import AVKit
import SwiftUI

#if os(macOS)
typealias Representable = NSViewControllerRepresentable
typealias ViewControllerType = NSViewController
#else
typealias Representable = UIViewControllerRepresentable
typealias ViewControllerType = AVPlayerViewController
#endif

struct PlayerViewController: Representable {
    typealias NSViewControllerType = ViewControllerType
    
    let queue: DispatchQueue = DispatchQueue(label: "LoaderQueue")
    
    let videoURL: URL?
    let router: HLSURLRouter
    
    let loader: HLSCachingLoader
    
    private var player: AVPlayer {
        if let asset = asset(with: videoURL!, router: router, loader: loader) {
            let playerItem = AVPlayerItem(asset: asset)
            playerItem.preferredForwardBufferDuration = TimeInterval(90)
            return AVPlayer(playerItem: playerItem)
        } else {
            let options = [
                AVURLAssetPreferPreciseDurationAndTimingKey: true,
                AVURLAssetAllowsCellularAccessKey: true
            ]
            let asset = AVURLAsset(url: videoURL!, options: options)
            let playerItem = AVPlayerItem(asset: asset)
            playerItem.preferredForwardBufferDuration = TimeInterval(90)
            return AVPlayer(playerItem: playerItem)
        }
    }
    
    func makeNSViewController(context: Context) -> NSViewControllerType {
        makeViewController(context: context)
    }
    
    func makeUIViewController(context: Context) -> NSViewControllerType {
        makeViewController(context: context)
    }
    
    func makeViewController(context: Context) -> NSViewControllerType {
#if os(macOS)
        //TODO: add player to macOS
        let controller = NSViewController()
#else
        let controller = AVPlayerViewController()
        controller.modalPresentationStyle = .fullScreen
        controller.player = player
        controller.player?.play()
#endif
        return controller
    }
    
    func updateNSViewController(_ playerController: NSViewControllerType, context: Context) {}
    func updateUIViewController(_ playerController: NSViewControllerType, context: Context) {}
    
    /// Creates a caching AVURLAsset from a source URL.
    /// - Parameters:
    ///   - url: Original remote media URL.
    ///   - cache: A configured URLCache.
    /// - Returns: An AVURLAsset with caching support.
    func asset(with url: URL, router: HLSURLRouter, loader: HLSCachingLoader) -> AVURLAsset? {
//        if let data = try? Data(contentsOf: url, options: .uncached) {
//            let rewrittenData = rewritePlaylist(data, router: router)
//            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("local_playlist.m3u8")
//            try? rewrittenData.write(to: tempURL)
//
//            let fakeURL = router.register(tempURL)
//            let asset = AVURLAsset(url: fakeURL)
//            asset.resourceLoader.setDelegate(loader, queue: DispatchQueue(label: "LoaderQueue"))
//            
//            return asset
//        } else {
            return nil
        //}
    }
    
    func rewritePlaylist(_ rawData: Data, router: HLSURLRouter) -> Data {
        guard let text = String(data: rawData, encoding: .utf8) else { return rawData }

        let rewritten = text.split(separator: "\n").map { line -> String in
            if line.hasPrefix("#") {
                return String(line)
            }
            if let originalURL = URL(string: String(line)),
               let fakeURL = router.register(originalURL) as URL? {
                return fakeURL.absoluteString
            }
            return String(line)
        }.joined(separator: "\n")

        return Data(rewritten.utf8)
    }
}
