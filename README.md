# Flutter Chat Application

A demo Flutter application built as part of the **Qurinom Solutions assignment**.  
The app includes login functionality, user roles (Customer & Vendor), chat list, chat details, and socket-based real-time messaging.  
The project follows **MVVM architecture** and uses **Bloc state management**.

---

## 🚀 Features
- **Login** with email, password, and role (Customer/Vendor).
- **Role-based authentication**.
- **List of Chats**: Fetches user’s active chats from API.
- **Chat Detail Screen**: Displays chat history from API.
- **Send Messages** via API + WebSocket.
- **MVVM Architecture** with clean separation of layers.
- **Bloc State Management** for scalability and testability.

---

## 🏗️ Project Structure
lib/
├── main.dart
├── models/
│   ├── user_model.dart
│   ├── chat_model.dart
│   └── message_model.dart
├── repositories/
│   ├── auth_repository.dart
│   └── chat_repository.dart
├── blocs/
│   ├── auth/
│   │   ├── auth_bloc.dart
│   │   ├── auth_event.dart
│   │   └── auth_state.dart
│   └── chat/
│       ├── chat_bloc.dart
│       ├── chat_event.dart
│       └── chat_state.dart
├── views/
│   ├── login_screen.dart
│   ├── chat_list_screen.dart
│   └── chat_detail_screen.dart
└── services/
├── api_service.dart
└── socket_service.dart


## ▶️ Getting Started

### 1️⃣ Clone the repository

## flutter pub get

## flutter run
