//
//  GalleryDetails.swift
//  DG
//
//  Created by Scott McGhie on 2023-09-09.
//

import SwiftUI

struct GalleryDetails: View {
    var image: Image?
    var gallery: ArtGallery?
    @ObservedObject var queryArt: QueryArt
    @State var showingConfirmation = false
    var art1: Artwork = Artwork(id: "", artist: "", artistID: "", description: "", image: "", thumb: "", name: "", artFile: "")
    @EnvironmentObject var userID: UserMonitor

    var body: some View {
        VStack{
            Text("Art Gallery Details")
                .padding(.top, 10)
                .font(.headline)
                .foregroundColor(Color("contentfont"))
                .background(Color("bgdark"))
                .fontWeight(.bold)
            image!
                .resizable()
                .scaledToFill()
                .aspectRatio(contentMode: .fit)
                .frame(width: (UIScreen.main.bounds.width * 0.95))
            Text(gallery!.galleryName)
                .font(.headline)
            Spacer()
            VStack{
                HStack{
                    Text(gallery!.galleryDescription)
                    Spacer()
                }
                Spacer()
                Button {
                    showingConfirmation = true
                } label: {
                    Text("Load Gallery")
                        .font(.headline)
                        .frame(height:55)
                        .frame(maxWidth: .infinity)
                        .background(Color("itembg"))
                        .cornerRadius(10)
                }
                .confirmationDialog("View Gallery", isPresented: $showingConfirmation) {
                    Button("Load") {
                        NavigationLink(destination: AGContentView(artwork: art1, queryArt: queryArt, userId: userID.uI), label: {
                        })
                    }
                } message: {
                    Text("Are you sure you want to delete?")
                }
            }
            .padding(15)
            Spacer()
        }
        .foregroundColor(Color("contentfont"))
        .background(Color("bgdark"))
    }
}
