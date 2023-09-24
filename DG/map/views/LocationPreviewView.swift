//
//  LocationPreviewView.swift
//  DG
//
//  Created by Scott McGhie on 2023-08-28.
//

import SwiftUI

struct LocationPreviewView: View {
    
    @EnvironmentObject private var vm: MapViewModel
    @State var detailsShowing = false
    @State var image: Image?
    @ObservedObject var queryArt: QueryArt
    @EnvironmentObject var userID: UserMonitor
    
    let location: ArtGallery
    
    var body: some View {
        HStack (alignment: .bottom, spacing: 0){
            VStack(alignment: .leading, spacing: 16){
                imageSection
                titleSection
            }
            VStack (spacing: 8){
                if image != nil{
                    detailsButton
                }
                nextButton
            }
            .padding(.top, 75)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .offset(y: 65)
        )
        .cornerRadius(10)
        .sheet(isPresented: $detailsShowing, content: {
            GalleryDetails(image: image, gallery: location, queryArt: queryArt).environmentObject(userID)
        })
    }
}

extension LocationPreviewView {
    private var imageSection: some View{
        ZStack{
            AsyncImage(url: URL(string: location.galleryImage)) { image in
                HStack{
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 150)
                        .cornerRadius(10)
                        .task{
                            self.image = image
                        }
                }
            } placeholder: {
                Color.clear
                    .frame(width: 120, height: 150)
            }
        }
        .padding(6)
        .background(Color.white)
        .cornerRadius(10)
    }
    
    private var titleSection: some View{
        VStack (alignment: .leading, spacing: 4){
            Text(location.galleryName)
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    private var detailsButton: some View{
        Button {
            detailsShowing.toggle()
        } label: {
            Text("Details")
                .font(.headline)
                .frame(width: 125, height: 35)
        }
        .buttonStyle(.borderedProminent)
    }
    
    private var nextButton: some View{
        Button {
            vm.nextButtonPressed()
        } label: {
            Text("Next")
                .font(.headline)
                .frame(width: 125, height: 35)
        }
        .buttonStyle(.bordered)
    }
}


