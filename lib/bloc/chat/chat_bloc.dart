import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/api_service.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ApiService _apiService = ApiService();

  ChatBloc() : super(ChatInitial()) {
    on<LoadChats>(_onLoadChats);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
  }

  Future<void> _onLoadChats(LoadChats event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final chats = await _apiService.getUserChats(event.userId);
      emit(ChatsLoaded(chats: chats));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final messages = await _apiService.getChatMessages(event.chatId);
      emit(MessagesLoaded(messages: messages));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    try {
      final message = await _apiService.sendMessage(event.chatId, event.senderId, event.content);
      if (message != null) {
        emit(MessageSent(message: message));
        // Reload messages to show the sent message
        add(LoadMessages(chatId: event.chatId));
      }
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }
}
