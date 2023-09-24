//
//  SharedArt.swift
//  DG
//
//  Created by Scott McGhie on 2023-07-30.
//

import SwiftUI

struct SharedArt: View {
    
    var message: Message
    var userId: String
    @State var artwork: Artwork?
    @StateObject var queryArt = QueryArt()
    
    var body: some View {
        VStack(alignment: message.sender == userId ? .trailing : .leading){
            if let art = artwork{
                NavigationLink(destination: ArtDetailsView(artwork: art), label: {
                    VStack{
                        AsyncImage(url: URL(string: art.thumb)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .clipped()
                        } placeholder: {
                            Color.clear
                                .frame(width:50, height: 50)
                        }
                    }
                })
                .frame(maxWidth: 200, maxHeight: 250, alignment: message.sender == userId ? .trailing : .leading)
                .background(.blue)
                .cornerRadius(30)
                Text("\(message.timestamp.formatted(.dateTime.hour().minute()))")
                    .font(.caption2)
                    .foregroundColor(Color("subtitlemain"))
                    .padding(message.sender == userId ? .trailing : .leading)
            }
        }
        .padding(.horizontal, 30)
        .frame(maxWidth: .infinity, alignment: message.sender == userId ? .trailing : .leading)
        .onAppear{
            Task{
                artwork = try? await queryArt.getArtGallery(artworkId: message.artwork)
            }
        }
    }
}

