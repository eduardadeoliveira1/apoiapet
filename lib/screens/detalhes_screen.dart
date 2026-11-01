import 'package:flutter/material.dart';

import '../models/ponto_apoio.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/ponto_foto.dart';
import '../widgets/recurso_chip.dart';

/// Tela 3 — Detalhes do ponto (RF21–RF26).
class DetalhesScreen extends StatelessWidget {
  const DetalhesScreen({super.key, required this.ponto});
  final PontoApoio ponto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final animal = ponto.animalAtendido;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do ponto')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            PontoFoto(foto: ponto.foto),
            const SizedBox(height: 18),
            Text(ponto.titulo, style: tema.titleLarge),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final r in ponto.recursos) RecursoChip(recurso: r),
              ],
            ),
            if (animal != null) ...[
              const SizedBox(height: 14),
              _Secao(
                icone: animal.icone,
                titulo: 'Comida para',
                texto: animal.rotulo,
              ),
            ],
            const _Divisor(),
            _Secao(
                icone: Icons.place_rounded,
                titulo: 'Endereço',
                texto: ponto.endereco),
            const SizedBox(height: 14),
            _Secao(
                icone: Icons.flag_rounded,
                titulo: 'Ponto de referência',
                texto: ponto.referencia),
            const _Divisor(),
            _Secao(
                icone: Icons.notes_rounded,
                titulo: 'Descrição',
                texto: ponto.descricao),
            const _Divisor(),
            Text(
              'Cadastrado${ponto.cadastradoPor != null ? ' por ${ponto.cadastradoPor}' : ''} em ${formatarData(ponto.dataCadastro)}',
              style: tema.bodyMedium?.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.map_rounded),
              label: const Text('Voltar ao mapa'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divisor extends StatelessWidget {
  const _Divisor();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Divider(height: 1, thickness: 1.5),
      );
}

class _Secao extends StatelessWidget {
  const _Secao(
      {required this.icone, required this.titulo, required this.texto});
  final IconData icone;
  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
                color: AppColors.amarelo, shape: BoxShape.circle),
            child: Icon(icone, color: AppColors.cinza, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 13)),
                const SizedBox(height: 2),
                Text(texto, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      );
}
