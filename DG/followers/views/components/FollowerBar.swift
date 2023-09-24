//
//  FollowerBar.swift
//  DG
//
//  Created by Scott McGhie on 2023-07-29.
//

import SwiftUI

struct FollowerBar: View {
    
    var username: UserProfile?
    @StateObject var followerManager = FollowerManager()
    @State var followerCount = 0
    @State var followingCount = 0
    var count = 0
    
    var body: some View {
            HStack{
                VStack{
                    Text("\(count)")
                    Text("Posts")
                }
                .frame(width: UIScreen.main.bounds.width / 3)
                Spacer()
                NavigationLink(destination: FollowerView(followers: true, username: username!), label: {
                    VStack{
                        Text("\(followerCount)")
                        Text("Followers")
                    }
                })
                .frame(width: UIScreen.main.bounds.width / 3)
                Spacer()
                NavigationLink(destination: FollowerView(following: true, username: username!), label: {
                    VStack{
                        Text("\(followingCount)")
                        Text("Following")
                    }
                })
                .frame(width: UIScreen.main.bounds.width / 3)
            }
            .foregroundColor(Color("titlemain"))
            .onAppear{
                Task{
                    followerCount = try await followerManager.getFollowersCount(userId: username!.id)
                    followingCount = try await followerManager.getFollowingCount(userId: username!.id)
                }
            }
    }
}

struct FollowerBar_Previews: PreviewProvider {
    static var previews: some View {
        FollowerBar()
    }
}
