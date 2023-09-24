//
//  ARArtwork.swift
//  DG
//
//  Created by Scott McGhie on 2023-08-10.
//

import Foundation

struct ARArtwork: Identifiable, Hashable, Codable{
    var id : String
    var name: Int
    var image: String
    var artist: String
    var artistID: String
    var description: String
}
