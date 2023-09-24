//
//  ChatScreen.swift
//  DG
//
//  Created by Scott McGhie on 2023-07-27.
//

import SwiftUI


struct ChatScreen: View {
    
    @StateObject var viewModel: ChatViewModel
    
    var body: some View {
        VStack {
            VStack {
                if let image = viewModel.image{
                    ChatBanner(username: viewModel.username, image: image)
                }
                chatScrollView
            }
            .background(Color("menulight"))
            
            MessageField(userId: viewModel.userId ?? "", username: viewModel.username, conversationId: viewModel.conversation?.id ?? "")
                .background(Color("menudark"))
                .environmentObject(viewModel.messagesManager)
        }
        .background(Color("bgdark"))
        .onAppear(perform: viewModel.loadInitialContent)
        .onReceive(viewModel.messagesManager.$conversation, perform: viewModel.handleConversationUpdate)
        .onReceive(viewModel.messagesManager.$messages, perform: viewModel.handleMessagesUpdate)
    }
}

private extension ChatScreen {
    var chatScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                ForEach(viewModel.messagesManager.messages) { message in
                    MessageBubble(message: message, userId: viewModel.userId ?? "", loadedImageCount: $viewModel.imageLoadingState.loadedImageCount)
                }
                .onChange(of: viewModel.imageLoadingState.loadedImageCount, perform: { newValue in
                    viewModel.handleImageLoadingCountChange(newValue: newValue, proxy: proxy)
                })
            }
            .padding(.top, 10)
            .background(Color("bgdark"))
            .cornerRadius(30, corners: [.topLeft, .topRight])
            .onChange(of: viewModel.messagesManager.lastMessageId) { id in
                withAnimation {
                    proxy.scrollTo(id, anchor: .bottom)
                }
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatScreen()
//    }
//}
