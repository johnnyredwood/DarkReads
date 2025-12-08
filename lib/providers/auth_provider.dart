import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entidades/user.dart';
import '../services/auth_service.dart';
import 'service_providers.dart';
import 'favorites_provider.dart';
import 'lists_provider.dart';

// Provider del usuario actual
final currentUserProvider = StateProvider<User?>((ref) {
  return ref.watch(authServiceProvider).currentUser;
});

// Notifier de autenticación
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;
  final Ref _ref;

  AuthNotifier(this._authService, this._ref) : super(const AsyncValue.loading()) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = _authService.currentUser;
      state = AsyncValue.data(user);
      _ref.read(currentUserProvider.notifier).state = user;
      
      if (user != null) {
        _ref.read(databaseServiceProvider).setCurrentUser(user.id);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _authService.register(
        username: username,
        email: email,
        password: password,
      );
      state = AsyncValue.data(_authService.currentUser);
      
      _ref.read(currentUserProvider.notifier).state = _authService.currentUser;
      _ref.read(databaseServiceProvider).setCurrentUser(_authService.currentUser?.id);
      
      _ref.invalidate(favoriteBooksProvider);
      _ref.invalidate(favoriteListsProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final success = await _authService.login(email: email, password: password);
      state = AsyncValue.data(_authService.currentUser);
      
      _ref.read(currentUserProvider.notifier).state = _authService.currentUser;
      _ref.read(databaseServiceProvider).setCurrentUser(_authService.currentUser?.id);
      
      _ref.invalidate(favoriteBooksProvider);
      _ref.invalidate(favoriteListsProvider);
      
      return success;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AsyncValue.data(null);
    
    _ref.read(currentUserProvider.notifier).state = null;
    _ref.read(databaseServiceProvider).setCurrentUser(null);
    
    _ref.invalidate(favoriteBooksProvider);
    _ref.invalidate(favoriteListsProvider);
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService, ref);
});
