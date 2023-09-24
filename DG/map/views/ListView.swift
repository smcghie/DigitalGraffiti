//
//  ListView.swift
//  DG
//
//  Created by Scott McGhie on 2023-08-28.
//

import SwiftUI

struct ListView: View {
    @EnvironmentObject private var vm: MapViewModel
    var body: some View {
        List{
            ForEach(vm.galleries){ location in
                Button {
                    //vm.showNextLocation(location: location)
                    vm.selectPlace(place: location)

                } label: {
                    listRowView(location: location)

                }
                .padding(.vertical, 4)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
            .environmentObject(MapViewModel())
    }
}

extension ListView{
    
    private func listRowView(location: ArtGallery) -> some View{
        HStack{
                CachedImage(url: location.galleryImage)
                    .scaledToFill()
                    .frame(width: 45, height: 45)
                    .cornerRadius(10)
            VStack(alignment: .leading){
                Text(location.galleryName)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        
        }
    }
    
}
