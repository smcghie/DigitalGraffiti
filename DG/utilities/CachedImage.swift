//
//  CachedImage.swift
//  DG
//
//  Created by Scott McGhie on 2023-07-31.
//

import SwiftUI

struct CachedImage: View {
    
    @StateObject var imageSession: ImageSession
    
    init(url: String?){
        self._imageSession = StateObject(wrappedValue: ImageSession(url: url))
    }
    
    var body: some View {
        Group{
            VStack{
                if imageSession.image != nil {
                    Image(uiImage: imageSession.image!)
                        .resizable()
                        .scaledToFill()
                        .clipped()
                }else{
                    ProgressView()
                }
            }
        }.onAppear{
            imageSession.fetch()
        }
    }
}

struct CachedImage_Previews: PreviewProvider {
    static var previews: some View {
        CachedImage(url: nil)
    }
}
