//
//  ArtGallery.swift
//  DigitalGratiffi
//
//  Created by Scott McGhie on 2022-11-24.
//

import Foundation

struct ArtGallery: Encodable, Decodable {
        var mapUrl: String
        var nodePosition: [NodeData]
}
