import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../domain/entidades/user.dart';
import 'database_service.dart';

class AuthService {
  final DatabaseService _dbService = DatabaseService();
  User? _currentUser;
  
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  
  AuthService() {
    _loadSession();
  }
  
  Future<void> _loadSession() async {
    final userId = await _dbService.getCurrentSessionUserId();
    if (userId != null) {
      _currentUser = await _dbService.getUserById(userId);
      if (_currentUser != null) {
        _dbService.setCurrentUser(userId);
      }
    }
  }

  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  String _generateSalt(String email) {
    return email.toLowerCase() + 'darkreads_salt';
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      if (username.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
        throw Exception('Todos los campos son requeridos');
      }

      if (password.length < 6) {
        throw Exception('La contraseña debe tener al menos 6 caracteres');
      }

      if (await _dbService.isEmailRegistered(email)) {
        throw Exception('Este email ya está registrado');
      }

      if (await _dbService.isUsernameInUse(username)) {
        throw Exception('Este nombre de usuario ya está en uso');
      }

      final salt = _generateSalt(email);
      final passwordHash = _hashPassword(password, salt);
      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      
      final user = User(
        id: userId,
        username: username.trim(),
        email: email.trim().toLowerCase(),
        passwordHash: passwordHash,
        createdAt: DateTime.now(),
      );
      print('Guardando usuario: ${user.email}');
      await _dbService.saveUser(user);
      print('Usuario guardado exitosamente');
      
      _currentUser = user;
      _dbService.setCurrentUser(userId);
      await _dbService.setCurrentSession(userId);
      
      // Verificar que se guardó
      final saved = await _dbService.getUserByEmail(user.email);
      print('Verificación: Usuario ${saved != null ? "SÍ" : "NO"} está en la DB');
      
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      // Debug: Ver todos los usuarios registrados
      final allUsers = await _dbService.getAllUsers();
      print('Total usuarios en DB: ${allUsers.length}');
      for (var u in allUsers) {
        print('Usuario: ${u.email} (${u.username})');
      }
      print('Intentando login con: $email');
      
      final user = await _dbService.getUserByEmail(email);
      if (user == null) {
        print('Usuario no encontrado en la base de datos');
        throw Exception('Usuario no registrado. Por favor regístrate primero.');
      }

      print('Usuario encontrado: ${user.email}');
      
      final salt = _generateSalt(email);
      final passwordHash = _hashPassword(password, salt);

      if (user.passwordHash != passwordHash) {
        print('Contraseña incorrecta');
        throw Exception('Contraseña incorrecta');
      }

      print('Login exitoso para: ${user.email}');
      _currentUser = user;
      _dbService.setCurrentUser(user.id);
      await _dbService.setCurrentSession(user.id);
      return true;
    } catch (e) {
      print('Error en login: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _dbService.setCurrentSession(null);
  }

  Future<User?> getUserById(String userId) async {
    return await _dbService.getUserById(userId);
  }
}
