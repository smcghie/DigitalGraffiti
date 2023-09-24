//
//  Conversation2.swift
//  DG
//
//  Created by Scott McGhie on 2023-08-03.
//

import Foundation

struct Conversation: Identifiable, Codable, Equatable {
    var id: String
    var lastMsg: String
    var lastMessageTimeStamp: Date
    var lastMessageSender: String
    var participant1: String
    var participant2: String
}
