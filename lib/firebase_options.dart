// ARQUIVO PROVISÓRIO.
//
// Este arquivo será SUBSTITUÍDO quando você rodar, na pasta do projeto:
//
//     flutterfire configure
//
// Ele conecta o app ao SEU projeto do Firebase. Enquanto isso não for feito, o
// app abre uma tela explicando o que falta (veja lib/main_firebase.dart).
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => throw UnsupportedError(
      'Firebase ainda não configurado. Rode "flutterfire configure" na pasta do projeto.');
}
