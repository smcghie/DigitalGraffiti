//
//  FollowerView.swift
//  DG
//
//  Created by Scott McGhie on 2023-07-30.
//

import SwiftUI

struct FollowerView: View {
    @StateObject var followerManager = FollowerManager()
    @EnvironmentObject var viewManager: ViewManager
    @State var followers = false
    @State var following = false
    var username: UserProfile?
    @State var update = false
    
    var body: some View {
            List{
                ForEach((followers ? followerManager.followers : followerManager.following)){ follower in
                    FollowerRow(userId: username!, username: follower, follower: followers ? true : false, update: $update)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color("bgdark"))
            }
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden)
            .background(Color("bgdark"))
            .foregroundColor(Color("contentfont"))
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(Color("menudark"), for: .tabBar)
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
            .onChange(of: update, perform: { _ in
                Task{
                    if followers {
                        try await followerManager.getFollowers(userId: username!.id)
                    }else if following{
                        try await followerManager.getFollowing(userId: username!.id)
                    }
                }
            })
    }
}

struct FollowerView_Previews: PreviewProvider {
    static var previews: some View {
        FollowerView()
    }
}
