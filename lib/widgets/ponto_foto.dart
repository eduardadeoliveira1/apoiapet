import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Mostra a foto do ponto: data URI base64 (Firestore), URL remota, arquivo
/// local (protótipo em memória) ou um marcador de posição quando não há imagem.
class PontoFoto extends StatefulWidget {
  const PontoFoto({
    super.key,
    required this.foto,
    this.aspectRatio = 16 / 10,
    this.radius = 20,
  });

  final String? foto;
  final double aspectRatio;
  final double radius;

  @override
  State<PontoFoto> createState() => _PontoFotoState();
}

class _PontoFotoState extends State<PontoFoto> {
  Uint8List? _bytes; // decodificado uma vez, não a cada rebuild

  @override
  void initState() {
    super.initState();
    _decodificar();
  }

  @override
  void didUpdateWidget(PontoFoto antigo) {
    super.didUpdateWidget(antigo);
    if (antigo.foto != widget.foto) _decodificar();
  }

  void _decodificar() {
    _bytes = null;
    final f = widget.foto;
    if (f != null && f.startsWith('data:')) {
      try {
        _bytes = base64Decode(f.substring(f.indexOf(',') + 1));
      } catch (_) {
        _bytes = null; // cai no marcador de posição
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.foto;
    Widget conteudo;
    if (f == null || f.isEmpty) {
      conteudo = _vazio();
    } else if (f.startsWith('data:')) {
      conteudo = _bytes == null
          ? _vazio()
          : Image.memory(_bytes!,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => _vazio());
    } else if (kIsWeb || f.startsWith('http') || f.startsWith('blob:')) {
      // Na web, a foto escolhida vira um endereço blob:, que o Image.network abre.
      conteudo = Image.network(f,
          fit: BoxFit.cover, errorBuilder: (_, __, ___) => _vazio());
    } else {
      conteudo = Image.file(File(f),
          fit: BoxFit.cover, errorBuilder: (_, __, ___) => _vazio());
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: AspectRatio(aspectRatio: widget.aspectRatio, child: conteudo),
    );
  }

  Widget _vazio() => Container(
        color: AppColors.amarelo,
        alignment: Alignment.center,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_camera_rounded, size: 40, color: AppColors.cinza),
            SizedBox(height: 6),
            Text('Foto do local',
                style: TextStyle(
                    color: AppColors.cinza, fontWeight: FontWeight.w700)),
          ],
        ),
      );
}
