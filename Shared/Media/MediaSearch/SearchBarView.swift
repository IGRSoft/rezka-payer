//
//  SearchBarView.swift
//  rezka-player
//
//  Created by vitalii on 10.11.2022.
//  Copyright © 2022 IGR Soft. All rights reserved.
//

import SwiftUI

struct SearchBarView<Content: View>: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = UINavigationController
    
    @Binding var text: String
    
    var placeholder: String = ""
    @ViewBuilder var content: () -> Content

    class Coordinator: NSObject, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {

        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }
        
        func updateSearchResults(for searchController: UISearchController) {
            if( self.text != searchController.searchBar.text ) {
                self.text = searchController.searchBar.text ?? ""
            }
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        }

        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        }
    }

    func makeCoordinator() -> SearchBarView.Coordinator {
        return Coordinator(text: $text)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<SearchBarView>) -> UIViewControllerType {
        let topController = UIHostingController(rootView: content() )
        
        let searchController =  UISearchController(searchResultsController: topController)
        searchController.searchResultsUpdater = context.coordinator
        searchController.searchBar.placeholder = placeholder
        
        let searchContainer = UISearchContainerViewController(searchController: searchController)
        let searchNavigationController = UINavigationController(rootViewController: searchContainer)

        return searchNavigationController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<SearchBarView>) {
        
        if let vc = uiViewController.children.first as? UISearchContainerViewController {
            if let searchResultController = vc.searchController.searchResultsController, let host = searchResultController as? UIHostingController<Content> {
                
                host.rootView = content()
            }
        }
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView(text: .constant("")) {
        }
    }
}
