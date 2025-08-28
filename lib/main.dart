import 'package:chatbot/view/chat_list_screen.dart';
import 'package:chatbot/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'bloc/auth/auth_bloc.dart';
import 'bloc/auth/auth_event.dart';
import 'bloc/auth/auth_state.dart';
import 'bloc/chat/chat_bloc.dart';
import 'bloc/chat/chat_event.dart';
import 'models/user_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc()..add(CheckAuthStatus()),
          ),
          BlocProvider(create: (context) => ChatBloc()),
        ],
        child: AppNavigator(),
      ),
    );
  }
}

class AppNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is AuthAuthenticated) {
          // Automatically load chats when user is authenticated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.read<ChatBloc>().isClosed) {
              context.read<ChatBloc>().add(LoadChats(userId: state.user.id));
            }
          });
          return ChatListScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}