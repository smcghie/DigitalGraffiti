//
//  ArtGallery.swift
//  DG
//
//  Created by Scott McGhie on 2023-08-10.
//

import Foundation

struct ArtGallery: Identifiable, Decodable, Equatable {
        var galleryId: String
        var galleryName: String
        var galleryDescription: String
        var galleryImage: String
        var nodePosition: [NodeData]
        var coordinates: [Double]
    
        var id: String {
            galleryId
        }
        
        static func == (lhs: ArtGallery, rhs: ArtGallery) -> Bool {
            lhs.galleryId == rhs.galleryId
        }
}
