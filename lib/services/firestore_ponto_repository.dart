import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ponto_apoio.dart';
import 'ponto_repository.dart';

/// Pontos de apoio no Cloud Firestore (plano gratuito Spark, sem Storage).
///
/// - Coleção: `pontos_apoio/{id}`
/// - A foto é reduzida no aparelho (image_picker) e gravada no próprio
///   documento, como texto base64, no campo `fotoBase64`.
/// - Leitura em tempo real dos pontos ativos
/// - Gravação em uma única operação: valida, cria o id e grava o documento
///   já com a foto. Não existe etapa intermediária, então não sobra foto órfã.
class FirestorePontoRepository extends PontoRepository {
  FirestorePontoRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  static const colecao = 'pontos_apoio';

  /// Limite do campo `fotoBase64` (caracteres). Precisa ser igual ao da regra
  /// em firebase/firestore.rules. ~400 mil caracteres = ~300 KB de imagem,
  /// bem abaixo do limite de 1 por documento do Firestore.
  static const maxFotoBase64 = 400000;

  final FirebaseFirestore _db;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  List<PontoApoio> _pontos = const [];
  String? _erro;

  @override
  List<PontoApoio> get pontos => _pontos;

  @override
  String? get erroCarregamento => _erro;

  @override
  Future<void> carregar() async {
    await _sub?.cancel();
    _erro = null;
    _sub = _db
        .collection(colecao)
        .where('pontoAtivo', isEqualTo: true)
        .snapshots()
        .listen(
      (snap) {
        _pontos = snap.docs.map(_converter).whereType<PontoApoio>().toList();
        _erro = null;
        notifyListeners();
      },
      onError: (Object e) {
        _erro = _traduzir(e);
        notifyListeners();
      },
    );
  }

  @override
  Future<int> contarPontosDoUsuario(String usuarioId) async {
    final r = await _db
        .collection(colecao)
        .where('usuarioId', isEqualTo: usuarioId)
        .count()
        .get();
    return r.count ?? 0;
  }

  @override
  Future<PontoApoio> cadastrar(NovoPonto n) async {
    // 1. Validação (segunda barreira; as Security Rules são a terceira)
    if (!(n.possuiAgua || n.possuiComida || n.possuiAbrigo)) {
      throw RepositorioException('Selecione pelo menos um recurso.');
    }
    if (n.possuiComida && !(n.atendeCaes || n.atendeGatos)) {
      throw RepositorioException('Informe se a comida é para cães, gatos ou ambos.');
    }

    // 2. Identificador único (RN07)
    final ref = _db.collection(colecao).doc();

    try {
      // 3. Lê a foto (já reduzida pelo image_picker) e converte para base64 (RN06)
      final bytes = await File(n.fotoLocal).readAsBytes();
      final fotoBase64 = base64Encode(bytes);
      if (fotoBase64.length > maxFotoBase64) {
        throw RepositorioException(
            'A foto é muito grande. Escolha outra ou tire uma nova foto.');
      }
      final mime =
          n.fotoLocal.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
      final foto = 'data:$mime;base64,$fotoBase64';

      // 4. Grava o ponto com a foto no mesmo documento (RN05: sem comida, animais ficam falsos)
      await ref.set({
        'usuarioId': n.usuarioId,
        'cadastradoPor': n.cadastradoPor,
        'latitude': n.latitude,
        'longitude': n.longitude,
        'endereco': n.endereco,
        'referencia': n.referencia,
        'descricao': n.descricao,
        'possuiAgua': n.possuiAgua,
        'possuiComida': n.possuiComida,
        'possuiAbrigo': n.possuiAbrigo,
        'atendeCaes': n.possuiComida && n.atendeCaes,
        'atendeGatos': n.possuiComida && n.atendeGatos,
        'pontoAtivo': n.pontoAtivo,
        'fotoBase64': fotoBase64,
        'dataCadastro': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 20));

      // 5. Sucesso: o listener atualiza o mapa (RF10)
      return PontoApoio(
        id: ref.id,
        usuarioId: n.usuarioId,
        latitude: n.latitude,
        longitude: n.longitude,
        endereco: n.endereco,
        referencia: n.referencia,
        descricao: n.descricao,
        possuiAgua: n.possuiAgua,
        possuiComida: n.possuiComida,
        possuiAbrigo: n.possuiAbrigo,
        atendeCaes: n.possuiComida && n.atendeCaes,
        atendeGatos: n.possuiComida && n.atendeGatos,
        pontoAtivo: n.pontoAtivo,
        foto: foto,
        dataCadastro: DateTime.now(),
        cadastradoPor: n.cadastradoPor,
      );
    } on RepositorioException {
      rethrow;
    } on TimeoutException {
      throw RepositorioException(
          'A conexão está muito lenta e o ponto não foi salvo. Tente novamente.');
    } on FirebaseException catch (e) {
      throw RepositorioException(_traduzir(e));
    } catch (_) {
      throw RepositorioException(
          'Não foi possível salvar o ponto. Tente novamente.');
    }
  }

  PontoApoio? _converter(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final d = doc.data();
      final ts = d['dataCadastro'];
      final b64 = d['fotoBase64'] as String?;
      return PontoApoio(
        id: doc.id,
        usuarioId: d['usuarioId'] as String,
        latitude: (d['latitude'] as num).toDouble(),
        longitude: (d['longitude'] as num).toDouble(),
        endereco: d['endereco'] as String,
        referencia: d['referencia'] as String,
        descricao: d['descricao'] as String,
        possuiAgua: d['possuiAgua'] as bool,
        possuiComida: d['possuiComida'] as bool,
        possuiAbrigo: d['possuiAbrigo'] as bool,
        atendeCaes: (d['atendeCaes'] as bool?) ?? false,
        atendeGatos: (d['atendeGatos'] as bool?) ?? false,
        pontoAtivo: (d['pontoAtivo'] as bool?) ?? true,
        foto: (b64 == null || b64.isEmpty)
            ? null
            : 'data:image/jpeg;base64,$b64',
        // logo após gravar, o servidor ainda não devolveu a data
        dataCadastro: ts is Timestamp ? ts.toDate() : DateTime.now(),
        cadastradoPor: d['cadastradoPor'] as String?,
      );
    } catch (_) {
      return null; // documento malformado é ignorado
    }
  }

  static String _traduzir(Object e) {
    if (e is FirebaseException) {
      switch (e.code) {
        case 'permission-denied':
        case 'unauthorized':
        case 'unauthenticated':
          return 'Você não tem permissão para esta ação. Entre novamente e tente de novo.';
        case 'unavailable':
        case 'network-request-failed':
        case 'retry-limit-exceeded':
          return 'Sem conexão com a internet. Verifique e tente novamente.';
        case 'quota-exceeded':
          return 'O limite gratuito do Firebase foi atingido. Tente mais tarde.';
      }
    }
    return 'Não foi possível concluir a operação. Tente novamente.';
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
