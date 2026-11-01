import 'package:flutter/material.dart';

import '../models/recurso.dart';
import '../theme/app_theme.dart';

/// Legenda do mapa (água, comida, abrigo). Tocar em um item filtra os pontos.
class LegendaFiltro extends StatelessWidget {
  const LegendaFiltro({super.key, required this.ativos, required this.onToggle});

  final Set<Recurso> ativos;
  final ValueChanged<Recurso> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        for (final r in Recurso.values)
          FilterChip(
            selected: ativos.contains(r),
            onSelected: (_) => onToggle(r),
            avatar: Icon(r.icone, size: 20, color: AppColors.cinza),
            label: Text(r.rotulo,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            showCheckmark: false,
            backgroundColor: AppColors.creme,
            selectedColor: AppColors.amarelo,
            side: BorderSide(
                color: ativos.contains(r)
                    ? AppColors.laranja
                    : AppColors.cinza.withAlpha(90),
                width: 1.8),
            materialTapTargetSize: MaterialTapTargetSize.padded,
          ),
      ],
    );
  }
}
