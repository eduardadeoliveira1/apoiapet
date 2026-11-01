import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';

/// Mostrada quando o Firebase ainda não foi configurado (ou falhou ao iniciar).
class ConfiguracaoFirebaseScreen extends StatelessWidget {
  const ConfiguracaoFirebaseScreen({super.key, required this.erro});
  final String erro;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Center(child: AppLogo(size: 80)),
            const SizedBox(height: 16),
            Text('Falta conectar ao Firebase',
                textAlign: TextAlign.center, style: tema.titleLarge),
            const SizedBox(height: 12),
            Text(
              'No terminal, dentro da pasta do projeto, rode:\n\n'
              'dart pub global activate flutterfire_cli\n'
              'flutterfire configure\n\n'
              'Depois feche e rode o app de novo (flutter run). '
              'Os passos completos estão no README.',
              style: tema.bodyLarge,
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.amarelo,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('Detalhe técnico:\n$erro',
                  style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}
