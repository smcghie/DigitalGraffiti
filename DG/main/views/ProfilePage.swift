//
//  ProfilePage.swift
//  DG
//
//  Created by Scott McGhie on 2023-06-21.
//

import SwiftUI

@MainActor
final class ProfilePageViewModel: ObservableObject {
    @Published var username: UserProfile?
    func getUsername(artistID: String) async throws {
        self.username = try await QueryArt.shared.getUsername(artist: artistID)
    }
}

struct ProfilePage: View {
    @StateObject var queryArt = QueryArt()
    @StateObject private var viewModel = ProfilePageViewModel()
    @EnvironmentObject var userID: UserMonitor
    @EnvironmentObject var viewManager: ViewManager
    var columnGrid: [GridItem] = [GridItem(.flexible(), spacing: 1), GridItem(.flexible(), spacing: 1), GridItem(.flexible(), spacing: 1)]
    var artistId: String = ""

    var body: some View {
        VStack {
            if let response = viewModel.username {
                ProfileHeader(queryArt: queryArt, username: response)
                    .padding([.top, .bottom, .leading, .trailing], 10)
            }
            ScrollView(.vertical, showsIndicators: false){
                VStack(spacing: 1){
                    if let response = viewModel.username {
                        FollowerBar(username: response, count: queryArt.artGallery.count)
                    }
                }
                .frame(width: UIScreen.main.bounds.width)
                LazyVGrid(columns: columnGrid, spacing: 1){
                        ForEach(queryArt.artGallery){ art in
                            NavigationLink(destination: ArtDetailsView(artwork: art).environmentObject(viewManager), label: {
                                VStack{
                                    CachedImage(url: art.thumb)
                                }
                                .scaledToFill()
                                .frame(width: (UIScreen.main.bounds.width / 3) - 1, height: (UIScreen.main.bounds.width / 3) - 1)
                                .clipped()
                            })
                        }
                }
            }
            .onAppear {
                self.queryArt.getArtGalleries(artistId: artistId)
                Task{
                    try? await self.viewModel.getUsername(artistID: artistId)
                }
            }

        }
        .toolbarBackground(Color("bgdark"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color("menudark"), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .background(Color("bgdark"))
        .foregroundColor(Color("contentfont"))
        .id(viewManager.profileRoot)
    }
}

//struct ProfilePage_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfilePage().environmentObject(UserMonitor()).environmentObject(ViewManager())
//    }
//}
