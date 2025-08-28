
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chat_model.dart';
import '../models/message_model.dart';

class ApiService {
  static const String baseUrl = 'http://45.129.87.38:6065';

  Future<Map<String, dynamic>> login(String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<Chat>> getUserChats(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chats/user-chats/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data.map((chat) => Chat.fromJson(chat)).toList();
        } else if (data is Map && data.containsKey('chats')) {
          return (data['chats'] as List).map((chat) => Chat.fromJson(chat)).toList();
        } else if (data is Map && data.containsKey('data')) {
          final chatData = data['data'];
          if (chatData is List) {
            return chatData.map((chat) => Chat.fromJson(chat)).toList();
          } else if (chatData is Map && chatData.containsKey('chats')) {
            return (chatData['chats'] as List).map((chat) => Chat.fromJson(chat)).toList();
          }
        }
        return [];
      } else {
        throw Exception('Failed to load chats');
      }
    } catch (e) {
      print('Error loading chats: $e');
      // Return sample data for testing if API fails
      return [
        Chat(
          id: '679bbd688c09df5b75cd1070',
          lastMessage: 'Hello! How are you?',
          lastMessageTime: DateTime.now().subtract(Duration(hours: 1)),
          participants: [userId, '673dbbf72330e08c323f4818'],
        ),
        Chat(
          id: '679bbd688c09df5b75cd1071',
          lastMessage: 'Thanks for your help!',
          lastMessageTime: DateTime.now().subtract(Duration(hours: 2)),
          participants: [userId, '673dbbf72330e08c323f4819'],
        ),
      ];
    }
  }

  Future<List<Message>> getChatMessages(String chatId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/get-messagesformobile/$chatId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data.map((msg) => Message.fromJson(msg)).toList();
        }
        return [];
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      print('Error loading messages: $e');
      return [];
    }
  }

  Future<Message?> sendMessage(String chatId, String senderId, String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages/sendMessage'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'chatId': chatId,
          'senderId': senderId,
          'content': content,
          'messageType': 'text',
          'fileUrl': '',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return Message.fromJson(data);
      } else {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }
}