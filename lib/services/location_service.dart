import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocalizacaoException implements Exception {
  LocalizacaoException(this.mensagem);
  final String mensagem;
  @override
  String toString() => mensagem;
}

/// Obtém a posição atual somente quando o usuário pede.
/// Sem rastreamento contínuo ou em segundo plano. A recusa da permissão não
/// impede o uso do mapa (RN09).
class LocationService {
  static Future<LatLng> posicaoAtual() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw LocalizacaoException(
          'O GPS está desligado. Ative a localização ou escolha o ponto manualmente no mapa.');
    }

    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    if (permissao == LocationPermission.denied ||
        permissao == LocationPermission.deniedForever) {
      throw LocalizacaoException(
          'Sem permissão de localização. Você ainda pode navegar pelo mapa e escolher o ponto manualmente.');
    }

    try {
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return LatLng(p.latitude, p.longitude);
    } catch (_) {
      throw LocalizacaoException(
          'Não foi possível obter sua localização agora. Tente novamente.');
    }
  }
}
