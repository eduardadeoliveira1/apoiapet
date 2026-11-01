import '../models/ponto_apoio.dart';
import 'ponto_repository.dart';

/// Implementação em memória, usada em testes e para trabalhar sem Firebase.
/// Os dados somem ao fechar o app.
class PontoRepositoryMemoria extends PontoRepository {
  PontoRepositoryMemoria() {
    _pontos.addAll(_exemplos());
  }

  final List<PontoApoio> _pontos = [];
  int _contador = 0;

  /// Para demonstrar o tratamento de erro de gravação (RNF08).
  bool simularFalhaNaGravacao = false;

  @override
  List<PontoApoio> get pontos => List.unmodifiable(_pontos);

  @override
  String? get erroCarregamento => null;

  @override
  Future<int> contarPontosDoUsuario(String usuarioId) async =>
      _pontos.where((p) => p.usuarioId == usuarioId).length;

  @override
  Future<void> carregar() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    notifyListeners();
  }

  @override
  Future<PontoApoio> cadastrar(NovoPonto n) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (simularFalhaNaGravacao) {
      throw RepositorioException(
          'Não foi possível salvar o ponto. Verifique sua conexão e tente novamente.');
    }

    if (!(n.possuiAgua || n.possuiComida || n.possuiAbrigo)) {
      throw RepositorioException('Selecione pelo menos um recurso.');
    }
    if (n.possuiComida && !(n.atendeCaes || n.atendeGatos)) {
      throw RepositorioException('Informe se a comida é para cães, gatos ou ambos.');
    }

    final ponto = PontoApoio(
      id: 'p_${DateTime.now().microsecondsSinceEpoch}_${_contador++}',
      usuarioId: n.usuarioId,
      latitude: n.latitude,
      longitude: n.longitude,
      endereco: n.endereco,
      referencia: n.referencia,
      descricao: n.descricao,
      possuiAgua: n.possuiAgua,
      possuiComida: n.possuiComida,
      possuiAbrigo: n.possuiAbrigo,
      // RN05: sem comida, os campos de animais ficam falsos.
      atendeCaes: n.possuiComida && n.atendeCaes,
      atendeGatos: n.possuiComida && n.atendeGatos,
      pontoAtivo: n.pontoAtivo,
      foto: n.fotoLocal,
      dataCadastro: DateTime.now(),
      cadastradoPor: n.cadastradoPor,
    );
    _pontos.add(ponto);
    notifyListeners(); // RF10: o mapa se atualiza
    return ponto;
  }

  /// Dados FICTÍCIOS de exemplo, em Rio do Sul/SC.
  static List<PontoApoio> _exemplos() {
    PontoApoio p(
      int n,
      double lat,
      double lon,
      String end,
      String ref,
      String desc, {
      bool agua = false,
      bool comida = false,
      bool abrigo = false,
      bool caes = false,
      bool gatos = false,
      bool ativo = true,
      String por = 'Maria Voluntária',
      String uid = 'u_demo',
    }) =>
        PontoApoio(
          id: 'seed_$n',
          usuarioId: uid,
          latitude: lat,
          longitude: lon,
          endereco: end,
          referencia: ref,
          descricao: desc,
          possuiAgua: agua,
          possuiComida: comida,
          possuiAbrigo: abrigo,
          atendeCaes: caes,
          atendeGatos: gatos,
          pontoAtivo: ativo,
          foto: null,
          dataCadastro: DateTime(2026, 10, 10 + n),
          cadastradoPor: por,
          );

    return [
      p(1, -27.2142, -49.6431, 'Rua XV de Novembro, 1200 - Centro',
          'Em frente à padaria, ao lado do poste',
          'Pote grande de água fresca, trocado todos os dias pela manhã.',
          agua: true),
      p(2, -27.2175, -49.6382, 'Av. Beira Rio, 350 - Bairro Sul',
          'Portão azul, perto do ponto de ônibus',
          'Comedouro com ração para cães, reabastecido duas vezes por semana.',
          comida: true, caes: true),
      p(3, -27.2108, -49.6475, 'Rua das Flores, 87 - Jardim Primavera',
          'Muro com grafite de um gato',
          'Água e ração para cães e gatos, na calçada, sob um toldo.',
          agua: true, comida: true, caes: true, gatos: true,
          por: 'João Protetor', uid: 'u_joao'),
      p(4, -27.2201, -49.6490, 'Rua Santos Dumont, 640 - Bela Vista',
          'Casinha de madeira ao lado do canteiro',
          'Casinha coberta com cobertor e pote de água ao lado.',
          agua: true, abrigo: true, por: 'João Protetor', uid: 'u_joao'),
      p(5, -27.2090, -49.6395, 'Praça da Matriz, s/n - Centro',
          'Atrás do coreto, perto do banco de madeira',
          'Ponto completo mantido por moradores: água, ração e abrigo contra chuva.',
          agua: true, comida: true, abrigo: true, caes: true, gatos: true),
      p(6, -27.2160, -49.6520, 'Rua Paraná, 15 - Barra do Trombudo',
          'Terreno baldio ao lado da oficina',
          'Ração para gatos. Ponto pausado temporariamente (inativo).',
          comida: true, gatos: true, ativo: false,
          por: 'João Protetor', uid: 'u_joao'),
    ];
  }
}
