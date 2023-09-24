//
//  Wall.swift
//  DG
//
//  Created by Scott McGhie on 2023-06-20.
//

import SwiftUI

struct Wall: View {
    @EnvironmentObject var viewManager: ViewManager
    @StateObject var queryArt = QueryArt()
    
    var columnGrid: [GridItem] = [GridItem(.flexible(), spacing: 1), GridItem(.flexible(), spacing: 1), GridItem(.flexible(), spacing: 1)]
    
    var body: some View {
        LazyVGrid(columns: columnGrid, spacing: 1){
            ForEach(queryArt.artGallery){ art in
                NavigationLink(destination: ArtDetailsView(artwork: art), label: {
                    VStack{
                        CachedImage(url: art.thumb)
                    }
                    .frame(width: (UIScreen.main.bounds.width / 3) - 1, height: (UIScreen.main.bounds.width / 3) - 1)
                    .clipped()
                })
            }
        }
        .id(viewManager.wallRoot)
        .onAppear{
            URLCache.shared.memoryCapacity = 1024 * 1024 * 64
            //print("cache size \((URLCache.shared.memoryCapacity / 1024)/1024) MB")
            queryArt.getAllArts()
        }
    }
}

struct Wall_Previews: PreviewProvider {
    static var previews: some View {
        Wall()
            .environmentObject(ViewManager())
            .preferredColorScheme(.dark)
        Wall()
            .preferredColorScheme(.light)
            .environmentObject(ViewManager())
    }
}
