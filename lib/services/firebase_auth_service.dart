import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/usuario.dart';
import 'auth_service.dart';

/// Login com Google via Firebase Authentication 
class FirebaseAuthService extends AuthService {
  FirebaseAuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance {
    _usuario = _mapear(_auth.currentUser);
    _sub = _auth.authStateChanges().listen((u) {
      _usuario = _mapear(u);
      notifyListeners();
    });
  }

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  StreamSubscription<User?>? _sub;
  Usuario? _usuario;

  @override
  Usuario? get usuario => _usuario;

  static Usuario? _mapear(User? u) {
    if (u == null) return null;
    final email = u.email ?? '';
    final nome = (u.displayName?.trim().isNotEmpty ?? false)
        ? u.displayName!.trim()
        : (email.isNotEmpty ? email.split('@').first : 'Usuário');
    return Usuario(id: u.uid, nome: nome, email: email);
  }

  @override
  Future<void> entrarComGoogle() async {
    try {
      final provedor = GoogleAuthProvider()
        ..addScope('email')
        ..setCustomParameters({'prompt': 'select_account'});
      final cred = await _auth.signInWithProvider(provedor);
      final user = cred.user;
      if (user != null) await _registrarUsuario(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_traduzir(e));
    } catch (_) {
      throw AuthException('Não foi possível entrar com o Google. Tente novamente.');
    }
  }

  /// Cria `usuarios/{uid}` no primeiro acesso e atualiza o último acesso nos
  /// demais. Falha aqui não impede o login.
  Future<void> _registrarUsuario(User user) async {
    try {
      final ref = _db.collection('usuarios').doc(user.uid);
      final doc = await ref.get();
      final dados = _mapear(user)!;
      if (doc.exists) {
        await ref.update({'ultimoAcesso': FieldValue.serverTimestamp()});
      } else {
        await ref.set({
          'nome': dados.nome,
          'email': dados.email,
          'dataCadastro': FieldValue.serverTimestamp(),
          'ultimoAcesso': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {
      // ignorado de propósito
    }
  }

  static String _traduzir(FirebaseAuthException e) {
    switch (e.code) {
      case 'web-context-canceled':
      case 'canceled':
      case 'popup-closed-by-user':
        return 'Login cancelado. Toque em "Entrar com Google" para tentar de novo.';
      case 'network-request-failed':
        return 'Sem conexão com a internet. Verifique e tente novamente.';
      case 'account-exists-with-different-credential':
        return 'Já existe uma conta com este e-mail usando outro método de login.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'operation-not-allowed':
        return 'O login com Google não está ativado no Firebase deste projeto.';
      default:
        return 'Não foi possível entrar com o Google (${e.code}). Tente novamente.';
    }
  }

  @override
  Future<void> sair() => _auth.signOut();

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
