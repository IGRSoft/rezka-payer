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
    
    let videoURL: URL?
        
    private var player: AVPlayer {
        let playerItem = AVPlayerItem(url: videoURL!)
        playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = false
        playerItem.preferredForwardBufferDuration = TimeInterval(30)
        return AVPlayer(playerItem: playerItem)
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
}
