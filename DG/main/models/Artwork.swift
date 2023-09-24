//
//  Artwork.swift
//  DG
//
//  Created by Scott McGhie on 2022-06-07.
//

import Foundation

struct Artwork: Identifiable, Codable, Equatable, Hashable{
    var id: String
    var artist: String
    var artistID: String
    var description: String
    var image: String
    var thumb: String
    var name: String
    var artFile: String
}
