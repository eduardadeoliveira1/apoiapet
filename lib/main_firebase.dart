import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'screens/configuracao_firebase_screen.dart';
import 'services/firebase_auth_service.dart';
import 'services/firestore_ponto_repository.dart';
import 'theme/app_theme.dart';

/// Versão com Firebase. Rodar: flutter run -t lib/main_firebase.dart
/// (exige o passo a passo de Firebase do README).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    // Firebase não configurado: mostra instruções em vez de fechar o app.
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: ConfiguracaoFirebaseScreen(erro: e.toString()),
    ));
    return;
  }

  runApp(ApoiaPetApp(
    auth: FirebaseAuthService(),
    pontos: FirestorePontoRepository(),
  ));
}
