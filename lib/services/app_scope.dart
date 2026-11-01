import 'package:flutter/widgets.dart';

import 'auth_service.dart';
import 'ponto_repository.dart';

/// Disponibiliza os serviços para toda a árvore de widgets.
/// Para trocar o mock pelo backend, basta passar outras implementações em main.dart (protótipo) ou main_firebase.dart.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.auth,
    required this.pontos,
    required super.child,
  });

  final AuthService auth;
  final PontoRepository pontos;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope não encontrado na árvore de widgets');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope old) =>
      auth != old.auth || pontos != old.pontos;
}
