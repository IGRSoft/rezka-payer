//
//  ImagePreviewView.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 13.10.2022.
//

import SwiftUI

struct ImagePreview : View {
    var url: URL
    
    var body: some View {
        CacheAsyncImage(url: url) { $0.view }
            .background(Color.clear)
            .cornerRadius(5)
            .shadow(radius: 5)
    }
}
