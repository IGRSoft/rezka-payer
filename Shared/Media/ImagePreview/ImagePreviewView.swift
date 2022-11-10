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
        ZStack {
            CacheAsyncImage(url: url) { phase in
                phase.view
            }
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(5)
        .shadow(radius: 5)
    }
}
