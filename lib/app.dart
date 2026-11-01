import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/map_screen.dart';
import 'services/app_scope.dart';
import 'services/auth_service.dart';
import 'services/ponto_repository.dart';
import 'theme/app_theme.dart';

class ApoiaPetApp extends StatelessWidget {
  const ApoiaPetApp({super.key, required this.auth, required this.pontos});

  final AuthService auth;
  final PontoRepository pontos;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      auth: auth,
      pontos: pontos,
      child: MaterialApp(
        title: 'ApoiaPet',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _AuthGate(),
      ),
    );
  }
}

/// Decide entre login e mapa conforme a sessão (RF02, RF03).
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = AppScope.of(context).auth;
    return ListenableBuilder(
      listenable: auth,
      builder: (_, __) =>
          auth.autenticado ? const MapScreen() : const LoginScreen(),
    );
  }
}
