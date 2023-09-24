//
//  CUProfileView.swift
//  DG
//
//  Created by Scott McGhie on 2023-06-22.
//

import SwiftUI
import Firebase
import FirebaseSharedSwift
import PhotosUI

struct NewArtworkView: View {
    
    var artist: String?
    @StateObject var vm: NewArtworkViewModel
    @State private var artItem: PhotosPickerItem?

    var body: some View {
        VStack {
            Spacer()
            ImagePickerView(artItem: $artItem, art: $vm.art, uImage: $vm.uImage)
            Spacer()
            InputFieldsView(name: $vm.name, desc: $vm.desc)
            UploadButtonView(action: {
                Task {
                    await vm.uploadArt(artist: artist ?? "")
                }
            })
            Spacer()
        }
        .background(Color("bgdark"))
        .foregroundColor(Color("contentfont"))
        .toolbarBackground(Color("bgdark"), for: .navigationBar)
    }
}

struct ImagePickerView: View {
    @Binding var artItem: PhotosPickerItem?
    @Binding var art: Image?
    @Binding var uImage: UIImage?
    
    var body: some View {
        VStack {
            PhotosPicker(selection: $artItem, matching: .images) {
                if (art != nil){
                    art!
                        .resizable()
                        .scaledToFit()
                        .frame(width: (UIScreen.main.bounds.width * 0.85), height: (UIScreen.main.bounds.height * 0.4))
                } else {
                    ImagePlaceholderView()
                }
            }
        }
        .padding([.all], 10)
        .onChange(of: artItem) { _ in
            Task {
                if let data = try? await artItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    uImage = uiImage
                    art = Image(uiImage: uiImage)
                }
            }
        }
    }
}

struct ImagePlaceholderView: View {
    var body: some View {
        VStack{
            Image(systemName: "photo.on.rectangle")
                .resizable()
                .frame(width: 50, height: 50)
            Text("Select image")
        }
        .foregroundColor(Color("titlemain"))
    }
}

struct InputFieldsView: View {
    @Binding var name: String
    @Binding var desc: String
    
    var body: some View {
        VStack{
            TextField("Artwork title...", text: $name)
                .padding()
                .cornerRadius(10)
                .background(Color.gray.opacity(0.4))
            TextField("Description...", text: $desc)
                .padding()
                .cornerRadius(10)
                .background(Color.gray.opacity(0.4))
        }
    }
}

struct UploadButtonView: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("UPLOAD")
                .font(.headline)
                .foregroundColor(Color("contentfont"))
                .frame(height:55)
                .frame(maxWidth: .infinity)
                .background(Color("itembg"))
                .cornerRadius(10)
        }
    }
}

//struct CUProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        let queryArt = QueryArt()
//        let fakeThis = Artwork(id: "01", artist: "asdf", artistID: "asdf", description: "asdf", image: "pp1", thumb: "", name: "Art Name", artFile: "")
//        CUProfileView(artwork: fakeThis, queryArt: queryArt).environmentObject(ViewManager())
//    }
//}
