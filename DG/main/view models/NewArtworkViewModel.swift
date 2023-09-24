//
//  NewArtworkViewModel.swift
//  DG
//
//  Created by Scott McGhie on 2023-09-11.
//

import Foundation
import SwiftUI
import PhotosUI

@MainActor
final class NewArtworkViewModel: NSObject, ObservableObject {
    
    @Published var desc = ""
    @Published var name = ""
    @Published var art: Image?
    @Published var uImage: UIImage?
    @Published var isVisible: Bool = false
    @Published var isUpdated: Bool = false
    @ObservedObject var queryArt: QueryArt
    @ObservedObject var userID: UserMonitor
    @ObservedObject var viewManager: ViewManager

    init(queryArt: QueryArt, userID: UserMonitor, viewManager: ViewManager) {
        self.queryArt = queryArt
        self.userID = userID
        self.viewManager = viewManager
    }
    
    func uploadArt(artist: String) async {
        do {
            let artwork = Artwork(id: "", artist: artist, artistID: "", description: desc, image: "", thumb: "", name: name, artFile: "")
            try await queryArt.uploadArt(artwork: artwork, artistId: userID.uI, uImage: uImage!)
            viewManager.isUpdated.toggle()
        } catch {
            print(error)
        }
    }
    
    func loadImageData(artItem: PhotosPickerItem?) async {
        if let data = try? await artItem?.loadTransferable(type: Data.self) {
            if let uiImage = UIImage(data: data) {
                self.uImage = uiImage
                self.art = Image(uiImage: uiImage)
                return
            }
        }
    }
}
