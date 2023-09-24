//
//  NodeData.swift
//  DG
//
//  Created by Scott McGhie on 2023-08-10.
//

import Foundation

struct NodeData: Encodable, Decodable {
    let name: String
    let id: String
    var positionX: Float
    var positionY: Float
    var positionZ: Float
    var nodeX: Float
    var nodeY: Float
    var nodeZ: Float
    var extentX: Float
}
