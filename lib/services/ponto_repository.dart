import 'package:flutter/foundation.dart';

import '../models/ponto_apoio.dart';

/// Dados enviados pelo formulário de cadastro (antes de ganhar id e data).
class NovoPonto {
  const NovoPonto({
    required this.usuarioId,
    required this.cadastradoPor,
    required this.latitude,
    required this.longitude,
    required this.endereco,
    required this.referencia,
    required this.descricao,
    required this.possuiAgua,
    required this.possuiComida,
    required this.possuiAbrigo,
    required this.atendeCaes,
    required this.atendeGatos,
    required this.pontoAtivo,
    required this.fotoLocal,
  });

  final String usuarioId;
  final String cadastradoPor;
  final double latitude;
  final double longitude;
  final String endereco;
  final String referencia;
  final String descricao;
  final bool possuiAgua;
  final bool possuiComida;
  final bool possuiAbrigo;
  final bool atendeCaes;
  final bool atendeGatos;
  final bool pontoAtivo;

  /// Caminho da foto no aparelho; o repositório a grava junto do ponto (RN06).
  final String fotoLocal;
}

class RepositorioException implements Exception {
  RepositorioException(this.mensagem);
  final String mensagem;
  @override
  String toString() => mensagem;
}

/// Contrato de acesso aos pontos (RF06, RF10, RN08).
/// Implementações: [PontoRepositoryMemoria] (testes) e [FirestorePontoRepository] (Firebase).
abstract class PontoRepository extends ChangeNotifier {
  /// Pontos conhecidos (inclui inativos; a tela do mapa filtra).
  List<PontoApoio> get pontos;

  /// Mensagem de erro de leitura (ex.: sem conexão), ou null se está tudo certo.
  String? get erroCarregamento;

  /// Começa (ou recomeça) a carregar os pontos ativos.
  Future<void> carregar();

  /// Quantidade de pontos cadastrados pelo usuário (tela de perfil).
  Future<int> contarPontosDoUsuario(String usuarioId);

  /// Valida, grava e devolve o ponto criado. Lança [RepositorioException].
  Future<PontoApoio> cadastrar(NovoPonto novo);
}
