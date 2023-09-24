//
//  Message.swift
//  DG
//
//  Created by Scott McGhie on 2023-07-28.
//

import Foundation

struct Message: Identifiable, Codable, Hashable {
    var id: String
    var text: String
    var sender: String
    var timestamp: Date
    var artwork: String
}
