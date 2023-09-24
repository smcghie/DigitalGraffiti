//
//  ChatViewModel.swift
//  DG
//
//  Created by Scott McGhie on 2023-09-10.
//

import Foundation
import SwiftUI

class ChatViewModel: ObservableObject {
    
    @Published var messagesManager = MessagesManager()
    @Published var imageLoadingState = ImageLoadingState()
    @Published var image: Image?

    var userId: String?
    var artistId: String?
    var username: UserProfile?
    var conversation: Conversation?

    init(userId: String?, username: UserProfile?, image: Image?, conversation: Conversation?) {
        self.userId = userId
        self.username = username
        self.image = image
        self.conversation = conversation
    }
    
    struct ImageLoadingState {
        var loadedImageCount: Int = 0
        var totalImageCount: Int = 0
    }
    
    func loadInitialContent() {
        Task {
            if let conversation = conversation {
                messagesManager.getMessages(conversationId: conversation.id)
            } else if let userId = userId, let usernameId = username?.id {
                messagesManager.getConversation(userId: userId, artistId: usernameId)
                if let newConversation = messagesManager.conversation {
                    messagesManager.getMessages(conversationId: newConversation.id)
                }
            }
        }
    }
    
    func handleConversationUpdate(_ update: Conversation?) {
        if let update = update {
            messagesManager.getMessages(conversationId: update.id)
        }
    }
    
    func handleMessagesUpdate(_ messages: [Message]) {
        imageLoadingState.totalImageCount = messages.filter { $0.artwork != "" }.count
        print("TOTAL", imageLoadingState.totalImageCount)
    }
    
    func handleImageLoadingCountChange(newValue: Int, proxy: ScrollViewProxy) {
        if newValue == imageLoadingState.totalImageCount {
            withAnimation {
                proxy.scrollTo(messagesManager.lastMessageId, anchor: .bottom)
            }
        }
    }
}

