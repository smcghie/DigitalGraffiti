//
//  ChatBanner.swift
//  DG
//
//  Created by Scott McGhie on 2023-07-27.
//

import SwiftUI

struct ChatBanner: View {

    var username: UserProfile?
    var image: Image?
    
    var body: some View {
        HStack(spacing: 15){
            if let image = image{
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                VStack(alignment: .leading){
                    Text(username!.name)
                        .font(.title).bold()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

        }
        .padding()
    }
}

//struct TitleRow_Previews: PreviewProvider {
//    static var previews: some View {
//        var userP = UserProfile(id: "", name: "Frank", avatarUrl: "https://firebasestorage.googleapis.com/v0/b/dg101-a56d8.appspot.com/o/avatarImages%2Fmo2PeDHTTAP75BMz5ul7ueqFzwK2?alt=media&token=090305d7-e653-4d7c-a342-b36fbb8b77ea")
//        TitleRow(username: userP)
//            .background(Color("black"))
//    }
//}
