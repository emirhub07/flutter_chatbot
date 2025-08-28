import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadChats extends ChatEvent {
  final String userId;
  LoadChats({required this.userId});

  @override
  List<Object> get props => [userId];
}

class LoadMessages extends ChatEvent {
  final String chatId;
  LoadMessages({required this.chatId});

  @override
  List<Object> get props => [chatId];
}

class SendMessage extends ChatEvent {
  final String chatId;
  final String senderId;
  final String content;

  SendMessage({required this.chatId, required this.senderId, required this.content});

  @override
  List<Object> get props => [chatId, senderId, content];
}