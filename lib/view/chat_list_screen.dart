import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/chat/chat_bloc.dart';
import '../bloc/chat/chat_event.dart';
import '../bloc/chat/chat_state.dart';
import '../models/user_model.dart';
import 'chat_detail.dart';

class ChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Chats'),
        backgroundColor: Colors.blue.shade700,
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  onTap: () async {
                    Navigator.pop(context);

                    // Clear shared preferences
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('user_data');

                    // Add logout event
                    if (!context.read<AuthBloc>().isClosed) {
                      context.read<AuthBloc>().add(LogoutRequested());
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            final currentUser = authState.user;

            return BlocBuilder<ChatBloc, ChatState>(
              builder: (context, chatState) {
                if (chatState is ChatLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (chatState is ChatsLoaded) {
                  if (chatState.chats.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No chats yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Start a conversation to see your chats here',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: chatState.chats.length,
                    itemBuilder: (context, index) {
                      final chat = chatState.chats[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Icon(
                              Icons.person,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          title: Text(
                            chat.participants.length > 1
                                ? 'Chat with User'
                                : 'Chat ${index + 1}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            chat.lastMessage,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${chat.lastMessageTime.hour}:${chat.lastMessageTime.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<ChatBloc>(), // reuse the existing ChatBloc
                                    child: ChatDetailScreen(
                                      chatId: chat.id,
                                      currentUser: currentUser!,
                                    ),
                                  ),
                                ),
                              );
                            }

                        ),
                      );
                    },
                  );
                } else if (chatState is ChatError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade400,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Error loading chats',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          chatState.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (!context.read<ChatBloc>().isClosed) {
                              context.read<ChatBloc>().add(
                                  LoadChats(userId: currentUser.id)
                              );
                            }
                          },
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                return Center(child: Text('Welcome to your chats!'));
              },
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            return FloatingActionButton(
              onPressed: () {
                if (!context.read<ChatBloc>().isClosed) {
                  context.read<ChatBloc>().add(
                      LoadChats(userId: authState.user.id)
                  );
                }
              },
              backgroundColor: Colors.blue.shade700,
              child: Icon(Icons.refresh, color: Colors.white),
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}