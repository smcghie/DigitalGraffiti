//
//  ProfileHeader.swift
//  DG
//
//  Created by Scott McGhie on 2023-07-13.
//

import SwiftUI

struct ProfileHeader: View {
    @ObservedObject var queryArt: QueryArt
    var art1: Artwork = Artwork(id: "", artist: "", artistID: "", description: "", image: "", thumb: "", name: "", artFile: "")
    @EnvironmentObject var userID: UserMonitor
    @EnvironmentObject var viewManager: ViewManager
    var username: UserProfile?

    var body: some View {
        HStack {
            if let username = username {
                ProfileImageSection(username: username)
                    .environmentObject(userID)
                    .environmentObject(viewManager)

                Spacer()
                
                NavigationButtonsSection(username: username, queryArt: queryArt, art1: art1)
                    .environmentObject(userID)
                    .environmentObject(viewManager)
            }
        }
        .foregroundColor(Color("titlemain"))
    }
}

struct ProfileImageSection: View {
    var username: UserProfile
    @State var image: Image?
    @EnvironmentObject var viewManager: ViewManager
    @EnvironmentObject var userID: UserMonitor
    @StateObject private var followerManager = FollowerManager()

    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: username.avatarUrl)) { phase in
                switch phase {
                case .success(let image):
                    HStack{
                        image
                            .resizable()
                            .frame(width: 50, height: 50)
                            .cornerRadius(50)
                        Text(username.name)
                            .font(.headline)
                            .foregroundColor(Color("contentfont"))
                            .fontWeight(.bold)
                        
                        Spacer()
                        if userID.uI != username.id {
                            Button {
                                followerManager.addFollower(artistId: username.id, follower1: userID.username!, follower2: username)
                            } label: {
                                Text("FOLLOW")
                            }
                            .padding(.trailing, 20)
                        }
                        NavigationLink(destination: ChatScreen(viewModel: ChatViewModel(userId: userID.uI, username: username, image: image, conversation: nil)).environmentObject(viewManager), label: {
                            Image(systemName: "paperplane.fill")
                        })
                    }
                case .failure(_):
                    Color.clear.frame(width: 50, height: 50)
                case .empty:
                    Color.clear.frame(width: 50, height: 50)
                @unknown default:
                    Color.clear.frame(width: 50, height: 50)
                }
            }
        }
    }
}

struct NavigationButtonsSection: View {
    var username: UserProfile
    @ObservedObject var queryArt: QueryArt
    var art1: Artwork
    @EnvironmentObject var userID: UserMonitor
    @EnvironmentObject var viewManager: ViewManager

    var body: some View {
        HStack {
            NavigationLink(destination: Home(queryArt: queryArt, username: userID.uI == username.id ? userID.username : username).environmentObject(userID), label: {
                Image(systemName: "map")
            })
            if userID.uI == username.id {
                NavigationLink(destination: NewArtworkView(artist: userID.user, vm: NewArtworkViewModel(queryArt: queryArt, userID: userID, viewManager: viewManager)), label: {
                    Image(systemName: "plus.app")
                })
                .navigationViewStyle(StackNavigationViewStyle())
            }
            
            NavigationLink(destination: AGContentView(artwork: art1, queryArt: queryArt, userId: userID.uI), label: {
                Image("hang")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 20, height: 20)
            })
        }
    }
}

//struct ProfileHeader_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileHeader()
//    }
//}
