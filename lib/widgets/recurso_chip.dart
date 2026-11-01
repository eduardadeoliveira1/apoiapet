import 'package:flutter/material.dart';

import '../models/recurso.dart';
import '../theme/app_theme.dart';

/// Etiqueta de um recurso (água, comida, abrigo) para listas e detalhes.
class RecursoChip extends StatelessWidget {
  const RecursoChip({super.key, required this.recurso});
  final Recurso recurso;

  @override
  Widget build(BuildContext context) => Chip(
        avatar: Icon(recurso.icone, size: 20, color: AppColors.cinza),
        label: Text(recurso.rotulo,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.amarelo,
        side: BorderSide.none,
        visualDensity: VisualDensity.comfortable,
      );
}
