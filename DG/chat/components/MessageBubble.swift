//
//  MessageBubble.swift
//  DG
//
//  Created by Scott McGhie on 2023-07-27.
//

import SwiftUI

struct MessageBubble: View {
    var message: Message
    var userId: String
    @State private var showTime = false
    @State var artwork: Artwork?
    @StateObject var queryArt = QueryArt()
    @Binding var loadedImageCount: Int
    
    var body: some View {
        VStack(alignment: message.sender == userId ? .trailing : .leading) {
            if let art = artwork {
                artworkSection(art: art)
            } else {
                messageSection
            }
        }
        .frame(maxWidth: .infinity, alignment: message.sender == userId ? .trailing : .leading)
        .padding(message.sender == userId ? .trailing : .leading)
        .padding(.horizontal, 10)
        .onAppear {
            loadArtworkIfNeeded()
        }
    }

    @ViewBuilder
    private var messageSection: some View {
        HStack {
            Text(message.text)
                .padding()
                .background(message.sender == userId ? Color("itembg") : Color("subtitlemain"))
                .cornerRadius(30)
        }
        .frame(maxWidth: 300, alignment: message.sender == userId ? .trailing : .leading)
        .onTapGesture {
            showTime.toggle()
        }
        
        if showTime {
            messageTimestamp
        }
    }
    
    private func artworkSection(art: Artwork) -> some View {
        NavigationLink(destination: ArtDetailsView(artwork: art)) {
            VStack(alignment: message.sender == userId ? .trailing : .leading){
                VStack {
                    AsyncImageView(url: URL(string: art.thumb)!) {
                        loadedImageCount += 1
                    }
                }
                .frame(maxWidth: 200, maxHeight: 250)
                .background(Color.blue)
                .cornerRadius(30)
                
                HStack {
                    messageTimestamp
                }
            }
        }
    }
    
    private var messageTimestamp: some View {
        Text("\(message.timestamp.formatted(.dateTime.hour().minute()))")
            .font(.caption2)
            .foregroundColor(Color("subtitlemain"))
            .padding(message.sender == userId ? .trailing : .leading)
    }
    
    private func loadArtworkIfNeeded() {
        if message.artwork != "" {
            Task {
                artwork = try? await queryArt.getArtGallery(artworkId: message.artwork)
            }
        }
    }
}

struct AsyncImageView: View {
    let url: URL
    let imageLoaded: () -> Void

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image.resizable().scaledToFit()
                    .onAppear (
                    perform: imageLoaded
                )
            case .failure:
                Image(systemName: "xmark.circle")
            @unknown default:
                EmptyView()
            }
        }
    }
}




//struct MessageBubble: View {
//    var message: Message
//    var userId: String
//    @State private var showTime = false
//    @State var artwork: Artwork?
//    @StateObject var queryArt = QueryArt()
//    @Binding var loadedImageCount: Int
//
//
//    var body: some View {
//        VStack(alignment: message.sender == userId ? .trailing : .leading){
//            if let art = artwork{
//                NavigationLink(destination: ArtDetailsView(artwork: art), label: {
//                    VStack{
//                        AsyncImageView(url: URL(string: art.thumb)!){
//                            loadedImageCount += 1
//                        }
//                    }
//                })
//                .frame(maxWidth: 200, maxHeight: 250, alignment: message.sender == userId ? .trailing : .leading)
//                .background(.blue)
//                .cornerRadius(30)
//                Text("\(message.timestamp.formatted(.dateTime.hour().minute()))")
//                    .font(.caption2)
//                    .foregroundColor(Color("subtitlemain"))
//                    .padding(message.sender == userId ? .trailing : .leading)
//            }else{
//                HStack {
//                    Text(message.text)
//                        .padding()
//                        .background(message.sender == userId ? Color("itembg") : Color("subtitlemain"))
//                        .cornerRadius(30)
//                }
//                .frame(maxWidth: 300, alignment: message.sender == userId ? .trailing : .leading)
//                .onTapGesture{
//                    showTime.toggle()
//                }
//                if showTime {
//                    Text("\(message.timestamp.formatted(.dateTime.hour().minute()))")
//                        .font(.caption2)
//                        .foregroundColor(Color("subtitlemain"))
//                        .padding(message.sender == userId ? .trailing : .leading)
//                }
//            }}
//        .frame(maxWidth: .infinity, alignment: message.sender == userId ? .trailing : .leading)
//        .padding(message.sender == userId ? .trailing : .leading)
//        .padding(.horizontal, 10)
//        .onAppear{
//            Task{
//                if message.artwork != "" {
//                    artwork = try? await queryArt.getArtGallery(artworkId: message.artwork)
//                }
//            }
//        }
//    }
//}
//
//struct AsyncImageView: View {
//    let url: URL
//    let imageLoaded: () -> Void
//
//    var body: some View {
//        AsyncImage(url: url) { phase in
//            switch phase {
//            case .empty:
//                ProgressView()
//            case .success(let image):
//                image.resizable().scaledToFit()
//                    .onAppear (
//                    perform: imageLoaded
//                )
//            case .failure:
//                Image(systemName: "xmark.circle")
//            @unknown default:
//                EmptyView()
//            }
//        }
//    }
//}

//struct MessageBubble_Previews: PreviewProvider {
//    static var previews: some View {
//        MessageBubble(message: Message(id: "12345", text: "asdasd1", received: false, timestamp: Date()))
//    }
//}
