import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_model.dart';
import '../../services/api_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService _apiService = ApiService();

  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }
  // Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
  //   emit(AuthLoading());
  //   try {
  //     final response = await _apiService.login(event.email, event.password, event.role);
  //
  //     // If API returned error
  //     if (response is Map && response.containsKey("msg")) {
  //       emit(AuthError(message: response["msg"]));
  //       return;
  //     }
  //
  //     final data = response['data'] ?? response;
  //     final userData = data['user'] ?? data;
  //     final token = data['token'];
  //
  //     final userDataToStore = {
  //       'id': userData['_id']?.toString() ?? userData['id']?.toString() ?? '',
  //       'email': userData['email']?.toString() ?? '',
  //       'role': userData['role']?.toString() ?? '',
  //       'token': token?.toString() ?? '',
  //       'name': userData['name']?.toString() ?? '',
  //     };
  //
  //     final user = User(
  //       id: userDataToStore['id']!,
  //       email: userDataToStore['email']!,
  //       role: userDataToStore['role']!,
  //       token: userDataToStore['token'],
  //     );
  //
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setString('user_data', json.encode(userDataToStore));
  //
  //     emit(AuthAuthenticated(user: user));
  //   } catch (e) {
  //     emit(AuthError(message: "Something went wrong. Please try again."));
  //   }
  // }
  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _apiService.login(event.email, event.password, event.role);

      // If API returned an error object
      if (response is Map && response.containsKey("msg")) {
        emit(AuthError(message: response["msg"]));
        return;
      }

      final data = response['data'] ?? response;
      final userData = data['user'] ?? data;
      final token = data['token'];

      final userDataToStore = {
        'id': userData['_id']?.toString() ?? userData['id']?.toString() ?? '',
        'email': userData['email']?.toString() ?? '',
        'role': userData['role']?.toString() ?? '',
        'token': token?.toString() ?? '',
        'name': userData['name']?.toString() ?? '',
      };

      final user = User(
        id: userDataToStore['id']!,
        email: userDataToStore['email']!,
        role: userDataToStore['role']!,
        token: userDataToStore['token'],
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', json.encode(userDataToStore));

      emit(AuthAuthenticated(user: user));
    } catch (e) {
      // If apiService throws, try to parse msg from error response
      final errorMessage = e.toString().replaceAll("Exception: ", "");
      emit(AuthError(message: errorMessage.isNotEmpty ? errorMessage : "Something went wrong"));
    }
  }


  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      emit(AuthInitial());
    } catch (e) {
      // Even if there's an error clearing preferences, emit initial state
      emit(AuthInitial());
    }
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');

      if (userData != null) {
        // Parse the stored JSON data
        final Map<String, dynamic> userMap = json.decode(userData);

        // Create user from the parsed data
        final user = User(
          id: userMap['id']?.toString() ?? '',
          email: userMap['email']?.toString() ?? '',
          role: userMap['role']?.toString() ?? '',
          token: userMap['token']?.toString(),
        );

        // Verify the user data is valid
        if (user.id.isNotEmpty && user.email.isNotEmpty) {
          emit(AuthAuthenticated(user: user));
        } else {
          // If user data is invalid, clear it and go to initial state
          await prefs.remove('user_data');
          emit(AuthInitial());
        }
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      // If there's any error parsing stored data, clear it and go to initial state
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('user_data');
      } catch (_) {
        // Ignore errors when clearing preferences
      }
      emit(AuthInitial());
    }
  }
}