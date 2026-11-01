import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/ponto_apoio.dart';
import '../models/recurso.dart';
import '../services/app_scope.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../utils/mapa.dart';
import '../widgets/legenda_filtro.dart';
import '../widgets/ponto_foto.dart';
import '../widgets/ponto_marker.dart';
import '../widgets/recurso_chip.dart';
import 'detalhes_screen.dart';
import 'cadastro_screen.dart';
import 'perfil_screen.dart';

/// Tela 2 — Mapa principal (RF05–RF10).
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapController = MapController();
  final Set<Recurso> _filtro = {};
  PontoApoio? _selecionado;
  LatLng? _minhaPosicao;
  bool _buscandoGps = false;
  bool _erroMapa = false;

  @override
  void initState() {
    super.initState();
    // RF10: carrega os pontos ao abrir.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppScope.of(context).pontos.carregar();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _aoFalharTile(TileImage tile, Object erro, StackTrace? stack) {
    if (_erroMapa) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_erroMapa) setState(() => _erroMapa = true);
    });
  }

  Future<void> _centralizar() async {
    if (_buscandoGps) return;
    setState(() => _buscandoGps = true);
    try {
      final pos = await LocationService.posicaoAtual();
      if (!mounted) return;
      setState(() => _minhaPosicao = pos);
      _mapController.move(pos, 16);
    } on LocalizacaoException catch (e) {
      _mensagem(e.mensagem);
    } finally {
      if (mounted) setState(() => _buscandoGps = false);
    }
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  void _alternarFiltro(Recurso r) => setState(() {
        _filtro.contains(r) ? _filtro.remove(r) : _filtro.add(r);
        _selecionado = null;
      });

  List<PontoApoio> _visiveis(List<PontoApoio> todos) => todos
      .where((p) => p.pontoAtivo)
      .where((p) => _filtro.isEmpty || _filtro.any(p.oferece))
      .toList();

  Future<void> _abrirCadastro() async {
    final salvo = await Navigator.of(context).push<PontoApoio>(
      MaterialPageRoute(
        builder: (_) => CadastroScreen(
            centroInicial: _minhaPosicao ?? _mapController.camera.center),
      ),
    );
    if (salvo != null && mounted) {
      setState(() => _selecionado = salvo.pontoAtivo ? salvo : null);
      if (salvo.pontoAtivo) _mapController.move(salvo.posicao, 16);
      _mensagem(salvo.pontoAtivo
          ? 'Ponto salvo! Obrigada por compartilhar cuidado 🐾'
          : 'Ponto salvo como inativo. Ele não aparece no mapa.');
    }
  }

  void _abrirDetalhes(PontoApoio p) => Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DetalhesScreen(ponto: p)));

  @override
  Widget build(BuildContext context) {
    final repo = AppScope.of(context).pontos;
    return Scaffold(
      body: ListenableBuilder(
        listenable: repo,
        builder: (context, _) {
          final pontos = _visiveis(repo.pontos);
          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: kCentroPadrao,
                  initialZoom: 14.5,
                  minZoom: 3,
                  maxZoom: 19,
                  onTap: (_, __) => setState(() => _selecionado = null),
                ),
                children: [
                  criarTileLayer(onErro: _aoFalharTile),
                  MarkerLayer(
                    markers: [
                      for (final p in pontos)
                        Marker(
                          point: p.posicao,
                          width: PontoMarker.largura(p),
                          height: PontoMarker.altura + 7,
                          alignment: Alignment.topCenter,
                          child: Semantics(
                            button: true,
                            label: p.titulo,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => setState(() => _selecionado = p),
                              child: PontoMarker(
                                  ponto: p,
                                  selecionado: p.id == _selecionado?.id),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (_minhaPosicao != null)
                    MarkerLayer(
                        markers: [marcadorPosicaoAtual(_minhaPosicao!)]),
                  criarAtribuicao(),
                ],
              ),

              // Topo: marca, perfil, legenda/filtro
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.creme,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: AppColors.laranja, width: 2),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.pets_rounded,
                                    color: AppColors.laranja, size: 22),
                                SizedBox(width: 8),
                                Text('ApoiaPet',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ),
                          const Spacer(),
                          _BotaoRedondo(
                            icone: Icons.person_rounded,
                            dica: 'Perfil e configurações',
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const PerfilScreen())),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LegendaFiltro(ativos: _filtro, onToggle: _alternarFiltro),
                      if (_erroMapa) ...[
                        const SizedBox(height: 10),
                        const AvisoMapaOffline(),
                      ],
                      if (repo.erroCarregamento != null) ...[
                        const SizedBox(height: 10),
                        AvisoMapaOffline(mensagem: repo.erroCarregamento!),
                      ],
                    ],
                  ),
                ),
              ),

              // Base: localização atual + cartão do ponto ou botão de cadastro
              Positioned(
                left: 16,
                right: 16,
                bottom: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _BotaoRedondo(
                          icone: Icons.my_location_rounded,
                          dica: 'Centralizar na minha localização',
                          carregando: _buscandoGps,
                          amarelo: true,
                          onTap: _centralizar,
                        ),
                        const SizedBox(height: 12),
                        if (_selecionado != null)
                          _CartaoResumo(
                            ponto: _selecionado!,
                            onDetalhes: () => _abrirDetalhes(_selecionado!),
                            onFechar: () =>
                                setState(() => _selecionado = null),
                          )
                        else
                          FilledButton.icon(
                            onPressed: _abrirCadastro,
                            icon: const Icon(Icons.add_location_alt_rounded),
                            label: const Text('Cadastrar ponto'),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BotaoRedondo extends StatelessWidget {
  const _BotaoRedondo({
    required this.icone,
    required this.dica,
    required this.onTap,
    this.amarelo = false,
    this.carregando = false,
  });

  final IconData icone;
  final String dica;
  final VoidCallback onTap;
  final bool amarelo;
  final bool carregando;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: dica,
        child: Material(
          color: amarelo ? AppColors.amarelo : AppColors.creme,
          shape: const CircleBorder(
              side: BorderSide(color: AppColors.laranja, width: 2)),
          elevation: 3,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 52,
              height: 52,
              child: carregando
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: CircularProgressIndicator(
                          strokeWidth: 3, color: AppColors.cinza),
                    )
                  : Icon(icone, color: AppColors.cinza, size: 26),
            ),
          ),
        ),
      );
}

class _CartaoResumo extends StatelessWidget {
  const _CartaoResumo(
      {required this.ponto, required this.onDetalhes, required this.onFechar});

  final PontoApoio ponto;
  final VoidCallback onDetalhes;
  final VoidCallback onFechar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.creme,
      elevation: 6,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onDetalhes,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 92,
                child: PontoFoto(
                    foto: ponto.foto, aspectRatio: 1, radius: 14),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ponto.titulo,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(ponto.endereco,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: [
                        for (final r in ponto.recursos) RecursoChip(recurso: r)
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('Toque para ver detalhes',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 13)),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Fechar',
                onPressed: onFechar,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
