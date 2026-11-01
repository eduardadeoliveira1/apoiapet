import 'package:flutter/foundation.dart';

import '../models/usuario.dart';
abstract class AuthService extends ChangeNotifier {
  Usuario? get usuario;
  bool get autenticado => usuario != null;

  /// Lança [AuthException] com mensagem amigável em caso de falha.
  Future<void> entrarComGoogle();
  Future<void> sair();
}

class AuthException implements Exception {
  AuthException(this.mensagem);
  final String mensagem;
  @override
  String toString() => mensagem;
}

/// Simula o login com Google (protótipo).
class MockAuthService extends AuthService {
  Usuario? _usuario;

  /// Útil para demonstrar a mensagem de erro da tela de login.
  bool simularFalha = false;

  @override
  Usuario? get usuario => _usuario;

  @override
  Future<void> entrarComGoogle() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (simularFalha) {
      throw AuthException(
          'Não foi possível entrar com o Google. Verifique sua conexão e tente novamente.');
    }
    _usuario = const Usuario(
      id: 'u_demo',
      nome: 'Maria Voluntária',
      email: 'maria.demo@apoiapet.app',
    );
    notifyListeners();
  }

  @override
  Future<void> sair() async {
    _usuario = null;
    notifyListeners();
  }
}
