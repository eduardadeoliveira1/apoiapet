import 'package:latlong2/latlong.dart';

import 'recurso.dart';

/// Ponto de apoio a animais de rua. Espelha o documento `pontos_apoio/{id}`
/// do Firestore (veja docs/MODELAGEM.md).
class PontoApoio {
  const PontoApoio({
    required this.id,
    required this.usuarioId,
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
    required this.foto,
    required this.dataCadastro,
    this.cadastradoPor,
  });

  final String id;
  final String usuarioId;
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

  /// Foto do ponto: data URI base64 (Firestore) ou caminho local (protótipo
  /// em memória). Nula quando não há imagem.
  final String? foto;
  final DateTime dataCadastro;

  /// Nome de quem cadastrou (vem da view `vw_ponto_mapa`).
  final String? cadastradoPor;

  LatLng get posicao => LatLng(latitude, longitude);

  List<Recurso> get recursos => [
        if (possuiAgua) Recurso.agua,
        if (possuiComida) Recurso.comida,
        if (possuiAbrigo) Recurso.abrigo,
      ];

  bool oferece(Recurso r) => recursos.contains(r);

  /// Só tem significado quando há comida (RN05).
  AnimalAtendido? get animalAtendido {
    if (!possuiComida) return null;
    if (atendeCaes && atendeGatos) return AnimalAtendido.ambos;
    if (atendeCaes) return AnimalAtendido.caes;
    if (atendeGatos) return AnimalAtendido.gatos;
    return null;
  }

  /// Ex.: "Água e comida", "Água, comida e abrigo".
  String get titulo {
    final nomes = recursos.map((r) => r.rotulo.toLowerCase()).toList();
    if (nomes.isEmpty) return 'Ponto de apoio';
    final texto = nomes.length == 1
        ? nomes.first
        : '${nomes.sublist(0, nomes.length - 1).join(', ')} e ${nomes.last}';
    return 'Ponto de $texto';
  }
}
