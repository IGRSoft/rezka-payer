//
//  MenuView.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 13.10.2022.
//

import SwiftUI

struct MenuView: View {
#if os(macOS)
    private static let kScreenHeight = NSScreen.main?.frame.size.height ?? 256
#else
    private static let kScreenHeight = UIScreen.main.bounds.size.height
#endif
    @Environment(\.presentationMode) var presentationMode
    var items: AnyView
    
    var body: some View {
        ZStack {
            Text("")
                .padding(4000)
                .background(.thinMaterial)
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                items
                    .padding()
            }
            .frame(height: MenuView.kScreenHeight - 64)
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView(items: AnyView(EmptyView()))
    }
}
