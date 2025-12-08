import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/gemini_service.dart';
import '../services/database_service.dart';

// Providers de servicios
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final geminiServiceProvider = Provider<GeminiService>((ref) => GeminiService());

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final database = DatabaseService();
  final authService = ref.watch(authServiceProvider);
  database.setCurrentUser(authService.currentUser?.id);
  return database;
});
