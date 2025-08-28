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

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _apiService.login(event.email, event.password, event.role);

      // Handle nested response structure
      final data = response['data'] ?? response;
      final userData = data['user'] ?? data;
      final token = data['token'];

      // Create user with token
      final user = User(
        id: userData['_id'] ?? userData['id'] ?? '',
        email: userData['email'] ?? '',
        role: userData['role'] ?? '',
        token: token,
      );

      // Save user data with token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', json.encode({
        'id': user.id,
        'email': user.email,
        'role': user.role,
        'token': token,
        'name': userData['name'] ?? '',
      }));

      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    emit(AuthInitial());
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      final user = User.fromJson(json.decode(userData));
      emit(AuthAuthenticated(user: user));
    } else {
      emit(AuthInitial());
    }
  }
}