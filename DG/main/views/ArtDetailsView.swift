//
//  ArtDetailsView.swift
//  DG
//
//  Created by Scott McGhie on 2021-10-30.
//

import SwiftUI

struct ArtDetailsView: View {
    @State var artwork: Artwork
    @StateObject private var viewModel = DetailsViewViewModel()
    @EnvironmentObject var viewManager: ViewManager
    @State private var zoomShowing = false
    @State private var image: Image?

    var body: some View {
        VStack {
            if let response = viewModel.username {
                ArtDetailsHeader(artwork: artwork, isVisible: viewModel.isVisible, username: response)
                    .environmentObject(viewManager)
                    .padding([.bottom, .leading, .top], 10)
                    .background(Color("bgdark"))
            }

            DetailsScrollView(artwork: $artwork, zoomShowing: $zoomShowing, image: $image)
                .background(Color("bgdark"))
        }
        .fullScreenCover(isPresented: $zoomShowing, content: {
            ImageZoom(image: $image)
        })
        .background(Color("bgdark"))
        .onAppear {
            viewModel.authenticate(artwork: artwork)
            Task {
                try? await viewModel.getUsername(artistID: artwork.artistID)
            }
        }
    }
}

struct DetailsScrollView: View {
    @Binding var artwork: Artwork
    @Binding var zoomShowing: Bool
    @Binding var image: Image?

    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                ArtworkImageView(artwork: $artwork, zoomShowing: $zoomShowing, image: $image)
                
                VStack {
                    TextSection(text: artwork.name, font: .headline)
                    TextSection(text: artwork.description)
                }
            }
        }
        .toolbarBackground(Color("bgdark"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

struct ArtworkImageView: View {
    @Binding var artwork: Artwork
    @Binding var zoomShowing: Bool
    @Binding var image: Image?

    var body: some View {
        if artwork.id != "" {
            HStack(alignment: .center) {
                Spacer()
                Button {
                    zoomShowing.toggle()
                } label: {
                    AsyncImage(url: URL(string: artwork.image)) { img in
                        img
                            .resizable()
                            .scaledToFill()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: (UIScreen.main.bounds.width * 0.95))
                            .task {
                                self.image = img
                            }
                    } placeholder: {
                        ProgressView().frame(width: UIScreen.main.bounds.width, height: 30)
                    }
                }
                Spacer()
            }
        }
    }
}

struct TextSection: View {
    var text: String
    var font: Font = .body

    var body: some View {
        HStack {
            Text(text)
                .font(font)
            Spacer()
        }
        .padding([.bottom, .leading, .top], 10)
    }
}

//struct ArtDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//
//        let fakeThis = Artwork(id: "01", artist: "asdf", artistID: "asdf", description: "asdf", image: "pp1", thumb: "pp1", name: "Art Name", artFile: "")
//        
//        ArtDetailsView(artwork: fakeThis)
//    }
//}
