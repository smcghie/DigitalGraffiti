//
//  FollowerRow.swift
//  DG
//
//  Created by Scott McGhie on 2023-07-30.
//

import SwiftUI

struct FollowerRow: View {
    var userId: UserProfile?
    var username: UserProfile?
    @State private var showingConfirmation = false
    @State var follower = false
    @StateObject var followerManager = FollowerManager()
    @Binding var update: Bool

    
    var body: some View {
        VStack {
            NavigationLink(destination: ProfilePage(artistId: username!.id), label:{
                HStack{
                    AsyncImage(url: URL(string : username!.avatarUrl)) { image in
                        image
                            .resizable()
                            .frame(width: 50, height: 50)
                    } placeholder: {
                        ProgressView()
                    }
                    HStack{
                        Text("\(username!.name)")
                            .font(.headline)
                            .foregroundColor(Color("contentfont"))
                        Spacer()
                    }
                }
                .padding([.leading, .trailing], 10)
            })

        }
        .swipeActions {
            Button("DELETE") {
                showingConfirmation = true
            }
            .tint(Color("titlemain"))
        }
        .confirmationDialog("Remove?", isPresented: $showingConfirmation) {
            Button("Remove") {
                followerManager.deleteFollower(follower: follower ? "followers" : "following", userId: userId!.id, followerId: username!.id)
                update.toggle()
            }
        } message: {
            Text("Are you sure you want to remove?")
        }
    }
}

//struct FollowerRow_Previews: PreviewProvider {
//    static var previews: some View {
//        FollowerRow()
//    }
//}

