import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../theme/app_theme.dart';

/// Centro inicial do mapa (Rio do Sul/SC) usado quando não há GPS.
const kCentroPadrao = LatLng(-27.2142, -49.6431);

const kTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const kPacote = 'br.edu.unidavi.apoiapet';

TileLayer criarTileLayer({ErrorTileCallBack? onErro}) => TileLayer(
      urlTemplate: kTileUrl,
      userAgentPackageName: kPacote,
      maxNativeZoom: 19,
      errorTileCallback: onErro,
    );

/// Atribuição obrigatória ao OpenStreetMap.
Widget criarAtribuicao() => const RichAttributionWidget(
      alignment: AttributionAlignment.bottomLeft,
      showFlutterMapAttribution: false,
      attributions: [TextSourceAttribution('© OpenStreetMap contributors')],
    );

/// Bolinha azul-escura da posição do usuário (usa só cores da paleta).
Marker marcadorPosicaoAtual(LatLng p) => Marker(
      point: p,
      width: 28,
      height: 28,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cinza,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.creme, width: 4),
          boxShadow: [
            BoxShadow(color: AppColors.cinza.withAlpha(90), blurRadius: 8),
          ],
        ),
      ),
    );

/// Banner exibido quando os tiles não carregam 
class AvisoMapaOffline extends StatelessWidget {
  const AvisoMapaOffline({
    super.key,
    this.mensagem = 'Não foi possível carregar o mapa. Verifique sua conexão.',
  });

  final String mensagem;

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.amarelo,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.cloud_off_rounded, color: AppColors.cinza),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  mensagem,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      );
}
