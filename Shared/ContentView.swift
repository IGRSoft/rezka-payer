//
//  ContentView.swift
//  Shared
//
//  Created by Vitalii Parovishnyk on 16.08.2022.
//

import SwiftUI

struct ContentView: View {
    private struct K {
        static var name = ""
        static var icon = "sparkles.tv"
    }
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @StateObject private var viewModel = ContentViewModel()
    
    @State var selectedCategory: CategoryList?
    
    @State var selectedItem: SubCategoryList?
    
    @State var pathCategory = NavigationPath()
    @State var pathColor    = NavigationPath()
    
    @State var sideBarVisibility = NavigationSplitViewVisibility.automatic
    @State var showToolbar = true
    
    var body: some View {
#if os(tvOS)
        NavigationView {
            TabView {
                ForEach(viewModel.categories, id: \.type) { category in
                    if category.type == .search {
                        MediaSearchView()
                            .tabItem {
                                Label(category.name, systemImage: category.iconName)
                            }
                    } else {
                        MediaContentView()
                            .environmentObject(MediaContentViewModel(category: category.type, subCategories: category.items))
                            .tabItem {
                                Label(category.name, systemImage: category.iconName)
                            }
                    }
                }
            }
            .onChange(of: horizontalSizeClass) { newValue in
                print("debug ContentView onChange \(String(describing: horizontalSizeClass)) -> \(String(describing: newValue))")
            }
            .overlay(overlayView)
            .onFirstAppear {
                selectedCategory = viewModel.categories.first
                refreshTask()
                
            }
        }
#else
        Group {
            if horizontalSizeClass == .regular {
                NavigationSplitView(columnVisibility: $sideBarVisibility) {
                    List(viewModel.categories, selection: $selectedCategory) { category in
                        CategoryListView(item: category)
                    }
                    .navigationSplitViewColumnWidth(200)
                    .navigationTitle(K.name)
                } content: {
                    CategoryView(horizontalSizeClass: horizontalSizeClass, category: selectedCategory, selection: $selectedItem)
                        .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 300)
                } detail: {
                    if let selectedCategory = selectedCategory {
                        MediaContentView()
                            .environmentObject(MediaContentViewModel(category: selectedCategory.type, subCategories: selectedCategory.items))
                    }
                    
                }
                .navigationSplitViewStyle(.prominentDetail)
                .toolbar {
                    EmptyView()
                }
            } else {
                NavigationSplitView(columnVisibility: $sideBarVisibility) {
                    List(viewModel.categories, selection: $selectedCategory) { category in
                        NavigationLink(value: category) {
                            Text(category.name)
                        }
                    }
                    .navigationTitle(K.name)
                } detail: {
                    NavigationStack {
                        CategoryView(horizontalSizeClass: horizontalSizeClass, category: selectedCategory, selection: $selectedItem)
                    }
                }
            }
        }
        .overlay(overlayView)
        .onFirstAppear {
            refreshTask()
            
        }
#if os(macOS)
        .frame(minWidth: 640, idealWidth: 1024, minHeight: 480, idealHeight: 768)
#endif
#endif
    }
    
    @ViewBuilder
    private var overlayView: some View {
        switch viewModel.phase {
        case .fetching:
            progress
        case .fetchingNextPage:
            progress
        case .success(let categories) where categories.isEmpty:
            EmptyPlaceholderView(text: "no categories", image: nil)
        case .failure(let error):
            RetryView(text: error.localizedDescription, retryAction: refreshTask)
        default: EmptyView()
        }
    }
    
    @ViewBuilder
    private var progress: some View {
        ProgressView()
            .padding(32)
            .background(.white)
            .tint(.black)
            .cornerRadius(8)
            .scaleEffect(1.4)
    }
    
    private func refreshTask() {
        Task {
            await viewModel.load()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
