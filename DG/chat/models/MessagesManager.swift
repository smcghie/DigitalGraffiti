//
//  MessagesManager.swift
//  DG
//
//  Created by Scott McGhie on 2023-07-27.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class MessagesManager: ObservableObject {
    @Published private(set) var messages: [Message] = []
    @Published private(set) var lastMessageId = ""
    @Published private(set) var conversations: [Conversation] = []
    @Published var conversation: Conversation?

    let db = Firestore.firestore()

    func deleteConversation(conversationId: String){
        db.collection("conversations").document(conversationId).delete(){ err in
            if let err = err {
              print("Error deleting conversation \(err)")
            }
            else {
              print("Conversation deleted")
            }
          }
    }

    func getConversation(userId: String, artistId: String) {
        var participants: [String] = []
        participants.append(userId)
        participants.append(artistId)
        participants.sort()
        db.collection("conversations")
            .whereField("participant1", isEqualTo: "\(participants[0])")
            .whereField("participant2", isEqualTo: "\(participants[1])").limit(to:1)
            .addSnapshotListener { querySnapshot, error in
                guard let document = querySnapshot?.documents.first else {
                    print("error fetching convos: \(String(describing: error))")
                    return
                }
                do{
                    let temp = try document.data(as: Conversation.self)
                    self.conversation = temp
                }catch{
                    print("Error fetching last convo: \(error)")
                }
            }
    }

    func getAllConversations(userId: String){
        db.collection("conversations")
            .whereFilter(Filter.orFilter([
                            Filter.whereField("participant1", isEqualTo: "\(userId)"),
                            Filter.whereField("participant2", isEqualTo: "\(userId)")
                        ]))
            .addSnapshotListener{ snapshot, error  in
                guard let documents = snapshot?.documents else{
                    print("error fetching conversations: \(String(describing: error))")
                    return
                }
                self.conversations = documents.compactMap{ document -> Conversation? in
                    do {
                        return try document.data(as: Conversation.self)
                    }catch{
                        print("Error decoding message document \(error)")
                        return nil
                    }
                }
                self.conversations.sort{$0.lastMessageTimeStamp > $1.lastMessageTimeStamp}
            }
    }

    func getMessages(conversationId: String) {
        db.collection("conversations").document("\(conversationId)")
            .collection("messages").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else{
                print("error fetching messages: \(String(describing: error))")
                return
            }
            self.messages = documents.compactMap{ document -> Message? in
                do {
                    return try document.data(as: Message.self)
                }catch{
                    print("Error decoding message document \(error)")
                    return nil
                }
            }
            self.messages.sort{$0.timestamp < $1.timestamp}
            if let id = self.messages.last?.id {
                self.lastMessageId = id
            }
        }
    }
    
    func sendMessage(conversationId: String, userId: String, artistId: String ,text: String, artwork: String){
        var participants: [String] = []
        participants.append(userId)
        participants.append(artistId)
        participants.sort()
        var convoId = conversationId
        if convoId == "" {
            convoId = "\(UUID())"
        }
        do{
            let id = UUID()
            let newMessage = Message(id: "\(id)", text: text, sender: userId, timestamp: Date(), artwork: artwork)
            try db.collection("conversations").document("\(convoId)")
                .collection("messages").document("\(UUID())").setData(from: newMessage)
        }catch{
            print("error adding message \(error)")
        }
        do{
            let newConversation = Conversation(id: "\(convoId)", lastMsg: text, lastMessageTimeStamp: Date(), lastMessageSender: userId, participant1: participants[0], participant2: participants[1])
            try db.collection("conversations").document(convoId)
                .setData(from: newConversation)
        }catch{
            print("error adding conversation \(error)")
        }
    }
}
