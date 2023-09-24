//
//  UserProfile.swift
//  DG
//
//  Created by Scott McGhie on 2023-07-12.
//

import Foundation

struct UserProfile: Identifiable, Codable{
    var id: String
    var name: String
    var avatarUrl: String
}
