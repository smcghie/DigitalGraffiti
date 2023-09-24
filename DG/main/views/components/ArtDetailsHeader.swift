//
//  ArtDetailsHeader.swift
//  DG
//
//  Created by Scott McGhie on 2023-07-13.
//

import SwiftUI

struct ArtDetailsHeader: View {
    @StateObject var queryArt = QueryArt()
    @State private var showingConfirmation = false
    @State private var backgroundColor = Color.white
    var artwork: Artwork?
    var isVisible: Bool = false
    var username: UserProfile?
    @EnvironmentObject var viewManager: ViewManager
    @EnvironmentObject var userMonitor: UserMonitor
    @State var friendsListShowing = false
    @State var image: Image?

    var body: some View {
        
        HStack{
            NavigationLink(destination: ProfilePage(artistId: artwork!.artistID).environmentObject(viewManager), label: {
                AsyncImage(url: URL(string: username!.avatarUrl)) { image in
                    HStack{
                        image
                            .resizable()
                            .frame(width: 50, height: 50)
                            .cornerRadius(50)
                            .task{
                                self.image = image
                            }
                        Text(username!.name)
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                } placeholder: {
                    Color.clear
                        .frame(width:50, height: 50)
                }
            })
            Spacer()
            Button{
                friendsListShowing.toggle()
            } label:{
                Text("SHARE")
            }
            
            NavigationLink(destination: ChatScreen(viewModel: ChatViewModel(userId: userMonitor.uI, username: username, image: image, conversation: nil)).environmentObject(viewManager), label: {
                Image(systemName: "paperplane.fill")
            })
            
            NavigationLink(destination: ARContentView(artwork: artwork!), label: {
                Image("hang")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 20, height: 20)
            })
            if isVisible {
                Button{
                    showingConfirmation = true
                } label: {
                    Image(systemName: "x.square")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                .confirmationDialog("Delete artwork", isPresented: $showingConfirmation) {
                    Button("Delete") {
                        queryArt.deleteArt(artwork: artwork!)
                        viewManager.isUpdated.toggle()
                        print("Is deleted: ", viewManager.isUpdated)
                        
                    }
                } message: {
                    Text("Are you sure you want to delete?")
                }
            }
        }
        .sheet(isPresented: $friendsListShowing, content: {
            FollowerSheet(followers: true, username: userMonitor.username, artwork: artwork!)
        })
        .presentationDetents([.medium, .fraction(0.7)])
        .padding([.leading, .trailing], 10)
    }
}

struct ArtDetailsHeader_Previews: PreviewProvider {
    static var previews: some View {
        let art1: Artwork = Artwork(id: "", artist: "", artistID: "", description: "", image: "", thumb: "", name: "", artFile: "")
        ArtDetailsHeader(artwork: art1)
    }
}
