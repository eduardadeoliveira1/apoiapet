import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../utils/mapa.dart';

/// Tela 5 — Seleção de localização. Devolve o [LatLng] escolhido ao formulário.
/// Funciona sem permissão de GPS (RN09): basta tocar no mapa.
class LocalizacaoScreen extends StatefulWidget {
  const LocalizacaoScreen({super.key, required this.centroInicial, this.inicial});

  final LatLng centroInicial;
  final LatLng? inicial;

  @override
  State<LocalizacaoScreen> createState() => _LocalizacaoScreenState();
}

class _LocalizacaoScreenState extends State<LocalizacaoScreen> {
  final _controller = MapController();
  LatLng? _escolhido;
  bool _buscandoGps = false;

  @override
  void initState() {
    super.initState();
    _escolhido = widget.inicial;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _usarMinhaLocalizacao() async {
    setState(() => _buscandoGps = true);
    try {
      final pos = await LocationService.posicaoAtual();
      if (!mounted) return;
      setState(() => _escolhido = pos);
      _controller.move(pos, 17);
    } on LocalizacaoException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.mensagem)));
    } finally {
      if (mounted) setState(() => _buscandoGps = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final escolhido = _escolhido;
    return Scaffold(
      appBar: AppBar(title: const Text('Escolher localização')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCenter: widget.inicial ?? widget.centroInicial,
              initialZoom: 16.5,
              minZoom: 3,
              maxZoom: 19,
              onTap: (_, ponto) => setState(() => _escolhido = ponto),
            ),
            children: [
              criarTileLayer(),
              if (escolhido != null)
                MarkerLayer(markers: [
                  Marker(
                    point: escolhido,
                    width: 56,
                    height: 56,
                    alignment: Alignment.topCenter,
                    child: const Icon(Icons.location_on_rounded,
                        size: 56, color: AppColors.laranja),
                  ),
                ]),
              criarAtribuicao(),
            ],
          ),
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Material(
              color: AppColors.amarelo,
              borderRadius: BorderRadius.circular(14),
              elevation: 2,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.touch_app_rounded, color: AppColors.cinza),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Toque no mapa para marcar onde fica o ponto.',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: FloatingActionButton.small(
                        heroTag: 'gps',
                        tooltip: 'Usar minha localização',
                        backgroundColor: AppColors.amarelo,
                        onPressed: _buscandoGps ? null : _usarMinhaLocalizacao,
                        child: _buscandoGps
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 3, color: AppColors.cinza))
                            : const Icon(Icons.my_location_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (escolhido != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: AppColors.creme,
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: Text(
                              '${escolhido.latitude.toStringAsFixed(5)}, ${escolhido.longitude.toStringAsFixed(5)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    FilledButton.icon(
                      onPressed: escolhido == null
                          ? null
                          : () => Navigator.of(context).pop(escolhido),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Confirmar localização'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.creme),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Voltar ao formulário'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
