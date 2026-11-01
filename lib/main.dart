import 'package:flutter/material.dart';

import 'app.dart';
import 'services/auth_service.dart';
import 'services/ponto_repository_memoria.dart';

/// PROTÓTIPO: roda o app completo SEM Firebase.
///
/// - Login com Google simulado (usuária "Maria Voluntária").
/// - Pontos de exemplo em Rio do Sul/SC, guardados só na memória.
/// - Cadastro de pontos funciona (foto da câmera/galeria incluída), mas tudo
///   some ao fechar o app.
///
/// Este é o main padrão: `flutter run` já abre o protótipo.
/// A versão com Firebase está em lib/main_firebase.dart.
///
/// Rodar:        flutter run
/// Gerar o APK:  flutter build apk --release
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ApoiaPetApp(
    auth: MockAuthService(),
    pontos: PontoRepositoryMemoria(),
  ));
}
