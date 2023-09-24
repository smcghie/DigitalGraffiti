//
//  DetailsViewModel.swift
//  DG
//
//  Created by Scott McGhie on 2023-09-11.
//

import Foundation
import SwiftUI

@MainActor
final class DetailsViewViewModel: ObservableObject {
    @Published var isVisible: Bool = false
    @Published var username: UserProfile?

    private var userID: String? {
        try? AuthenticationManager.shared.getAuthenticatedUser().uid
    }

    func authenticate(artwork: Artwork) {
        if let userID = userID, artwork.artistID == userID {
            isVisible = true
        }
    }
    
    func getUsername(artistID: String) async throws {
        username = try await QueryArt.shared.getUsername(artist: artistID)
    }
}
