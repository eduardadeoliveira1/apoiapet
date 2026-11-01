import 'package:flutter/material.dart';

import '../models/ponto_apoio.dart';
import '../theme/app_theme.dart';

/// Marcador do mapa: "pílula" com um ícone por recurso disponível.
class PontoMarker extends StatelessWidget {
  const PontoMarker({super.key, required this.ponto, this.selecionado = false});

  final PontoApoio ponto;
  final bool selecionado;

  static const double altura = 44;
  static double largura(PontoApoio p) => 14 + p.recursos.length * 26.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
          decoration: BoxDecoration(
            color: selecionado ? AppColors.laranja : AppColors.creme,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.laranja, width: 2.5),
            boxShadow: [
              BoxShadow(
                  color: AppColors.cinza.withAlpha(70),
                  blurRadius: 6,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final r in ponto.recursos)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(r.icone, size: 20, color: AppColors.cinza),
                ),
            ],
          ),
        ),
        // pequena ponta apontando para o local
        CustomPaint(
          size: const Size(14, 7),
          painter: _Ponta(selecionado ? AppColors.laranja : AppColors.creme),
        ),
      ],
    );
  }
}

class _Ponta extends CustomPainter {
  _Ponta(this.cor);
  final Color cor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = cor);
    canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.laranja
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);
  }

  @override
  bool shouldRepaint(_Ponta old) => old.cor != cor;
}
