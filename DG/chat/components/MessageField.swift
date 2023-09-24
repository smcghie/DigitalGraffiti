//
//  MessageField.swift
//  DG
//
//  Created by Scott McGhie on 2023-07-27.
//

import SwiftUI

struct MessageField: View {
    
    @State private var message = ""
    var userId: String?
    var username: UserProfile?
    var conversationId: String?
    @EnvironmentObject var messagesManager: MessagesManager
    
    var body: some View {
        HStack{
            CustomTextField(placeholder: Text("Enter message here"), text: $message)
            
            Button {
                let effectiveConversationId: String
                if let conversationId = conversationId, !conversationId.isEmpty {
                    effectiveConversationId = conversationId
                } else if messagesManager.messages.isEmpty {
                    effectiveConversationId = ""
                } else {
                    effectiveConversationId = messagesManager.conversation!.id
                }

                if let userId = userId, let artistId = username?.id {
                    messagesManager.sendMessage(conversationId: effectiveConversationId, userId: userId, artistId: artistId, text: message, artwork: "")
                }
                message = ""
            }label:{
                Image(systemName: "paperplane.fill")
                    .padding(10)
                    .background(Color("bgdark"))
                    .cornerRadius(50)
            }
        }
        .foregroundColor((Color("contentfont")))
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color("bgdark"))
        .cornerRadius(50)
        .padding()
    }
}

struct CustomTextField: View {
    var placeholder: Text
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .leading){
            if text.isEmpty {
                placeholder
                    .opacity(0.4)
            }
            TextField("", text: $text)
                .foregroundColor(Color("contentfont"))
        }
    }
}

struct MessageField_Previews: PreviewProvider {
    static var previews: some View {
        MessageField()
            .environmentObject(MessagesManager())
    }
}
