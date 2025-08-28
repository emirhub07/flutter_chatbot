import 'package:equatable/equatable.dart';

import '../../models/chat_model.dart';
import '../../models/message_model.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}
class ChatLoading extends ChatState {}
class ChatsLoaded extends ChatState {
  final List<Chat> chats;
  ChatsLoaded({required this.chats});

  @override
  List<Object> get props => [chats];
}
class MessagesLoaded extends ChatState {
  final List<Message> messages;
  MessagesLoaded({required this.messages});

  @override
  List<Object> get props => [messages];
}
class MessageSent extends ChatState {
  final Message message;
  MessageSent({required this.message});

  @override
  List<Object> get props => [message];
}
class ChatError extends ChatState {
  final String message;
  ChatError({required this.message});

  @override
  List<Object> get props => [message];
}