//
//  FollowerSheet.swift
//  DG
//
//  Created by Scott McGhie on 2023-07-30.
//

import SwiftUI

struct FollowerSheet: View {
    @StateObject var followerManager = FollowerManager()
    @EnvironmentObject var viewManager: ViewManager
    @State var followers = false
    @State var following = false
    var username: UserProfile?
    var artwork: Artwork?

    var body: some View {
        VStack{
            Text("Share With")
                .padding(.top, 10)
                .font(.headline)
                .fontWeight(.bold)
            List(followers ? followerManager.followers : followerManager.following){ follower in
                FollowerRowButton(username: username!, artwork: artwork!, follower: follower)
                    .listRowBackground(Color("bgdark"))
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(PlainListStyle())
        .scrollContentBackground(.hidden)
        .background(Color("bgdark"))
        .edgesIgnoringSafeArea(.all)
        .foregroundColor(Color("contentfont"))
        .toolbarBackground(.hidden, for: .tabBar)
        .toolbarBackground(Color("bgdark"), for: .tabBar)
        .navigationTitle(followers ? "Followers" : "Following").font(.headline)
        .onAppear{
            Task{
                if followers {
                    try await followerManager.getFollowers(userId: username!.id)
                }else if following{
                    try await followerManager.getFollowing(userId: username!.id)
                }
            }
        }
    }
}

struct FollowerRowButton: View {
    
    var username: UserProfile?
    var artwork: Artwork?
    var follower: UserProfile?
    @State var update = false
    @State var messageManager = MessagesManager()
    @State var showSent = false
    
    var body: some View{
        Button{
            Task{
                if let convo = messageManager.conversation {
                    messageManager.sendMessage(conversationId: convo.id, userId: username!.id, artistId: follower!.id, text: artwork!.name, artwork: artwork!.id)
                    messageManager.conversation = nil
                }else{
                    messageManager.sendMessage(conversationId: "", userId: username!.id, artistId: follower!.id, text: artwork!.name, artwork: artwork!.id)
                }
                showSent = true
            }
            } label: {
                FollowerRow(username: follower, update: $update)
            }
            .onAppear{
                    messageManager.getConversation(userId: username!.id, artistId: follower!.id)
            }
            .overlay(
                VStack {
                    if showSent {
                    Spacer()
                        ZStack{
                            RoundedRectangle(cornerRadius: 20).opacity(0.1)
                                .foregroundColor(Color("contentfont"))
                                .frame(width: 125, height: 50)
                            Text("Sent!").font(.title).opacity(0.5)
                        }
                        .task{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showSent = false
                            }
                        }
                    Spacer()
                }
            }.animation(.easeInOut(duration: 2))
        )
    }
}

struct FollowerSheetView_Previews: PreviewProvider {
    static var previews: some View {
        FollowerView()
    }
}
