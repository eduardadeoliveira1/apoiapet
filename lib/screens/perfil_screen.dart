import 'package:flutter/material.dart';

import '../services/app_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';

/// Tela 6 — Perfil e configurações (RF03).
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  Future<int>? _meusPontos;

  Future<void> _sair(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text('Você precisará entrar novamente para cadastrar pontos.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(90, 44)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmar != true || !context.mounted) return;
    final auth = AppScope.of(context).auth;
    Navigator.of(context).popUntil((r) => r.isFirst);
    await auth.sair(); // o _AuthGate volta para o login
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final usuario = scope.auth.usuario;
    final tema = Theme.of(context).textTheme;
    _meusPontos ??= usuario == null
        ? Future.value(0)
        : scope.pontos.contarPontosDoUsuario(usuario.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Center(
              child: CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.laranja,
                child: Text(usuario?.iniciais ?? '?',
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.cinza)),
              ),
            ),
            const SizedBox(height: 14),
            Text(usuario?.nome ?? 'Usuário',
                textAlign: TextAlign.center, style: tema.titleLarge),
            const SizedBox(height: 2),
            Text(usuario?.email ?? '',
                textAlign: TextAlign.center, style: tema.bodyLarge),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppColors.amarelo,
                  borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const Icon(Icons.pets_rounded, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FutureBuilder<int>(
                      future: _meusPontos,
                      builder: (_, snap) {
                        final String texto;
                        if (snap.hasError) {
                          texto = 'Não foi possível contar seus pontos agora.';
                        } else if (!snap.hasData) {
                          texto = 'Contando seus pontos...';
                        } else if (snap.data == 1) {
                          texto = 'Você cadastrou 1 ponto de apoio.';
                        } else {
                          texto = 'Você cadastrou ${snap.data} pontos de apoio.';
                        }
                        return Text(texto,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 16));
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _sair(context),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sair da conta'),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: AppColors.cinza.withAlpha(60), width: 1.5),
              ),
              child: Column(
                children: [
                  const AppLogo(size: 64),
                  const SizedBox(height: 10),
                  Text('ApoiaPet', style: tema.titleLarge),
                  const SizedBox(height: 4),
                  Text('Encontre pontos. Compartilhe cuidado.',
                      textAlign: TextAlign.center,
                      style: tema.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  Text(
                    'Aplicativo desenvolvido para a disciplina de "Desenvolvimento para plataformas móveis".',
                    textAlign: TextAlign.center,
                    style: tema.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Text('Versão 1.0.0 (protótipo)  •  Mapa © OpenStreetMap contributors',
                      textAlign: TextAlign.center,
                      style: tema.bodyMedium?.copyWith(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
