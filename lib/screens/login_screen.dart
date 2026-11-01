import 'package:flutter/material.dart';

import '../models/recurso.dart';
import '../services/app_scope.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';

/// Tela 1 — Login com Google (RF01).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _carregando = false;
  String? _erro;

  Future<void> _entrar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      await AppScope.of(context).auth.entrarComGoogle();
      // O _AuthGate troca para o mapa automaticamente.
    } on AuthException catch (e) {
      if (mounted) setState(() => _erro = e.mensagem);
    } catch (_) {
      if (mounted) setState(() => _erro = 'Algo deu errado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: Container(
              width: 260,
              height: 260,
              decoration: const BoxDecoration(
                  color: AppColors.amarelo, shape: BoxShape.circle),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                  color: AppColors.laranja.withAlpha(60),
                  shape: BoxShape.circle),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppLogo(size: 112),
                      const SizedBox(height: 20),
                      Text('ApoiaPet',
                          style: tema.headlineMedium?.copyWith(fontSize: 38)),
                      const SizedBox(height: 8),
                      Text(
                        'Encontre pontos. Compartilhe cuidado.',
                        textAlign: TextAlign.center,
                        style: tema.titleMedium,
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (final r in Recurso.values) ...[
                            _Bolha(icone: r.icone, rotulo: r.rotulo),
                            if (r != Recurso.values.last)
                              const SizedBox(width: 22),
                          ],
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Um mapa colaborativo de água, comida e abrigo para animais em situação de rua.',
                        textAlign: TextAlign.center,
                        style: tema.bodyLarge,
                      ),
                      const SizedBox(height: 32),
                      if (_erro != null) ...[
                        Semantics(
                          liveRegion: true,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.creme,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.erro, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    color: AppColors.erro),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(_erro!,
                                      style: const TextStyle(
                                          color: AppColors.erro,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      FilledButton.icon(
                        onPressed: _carregando ? null : _entrar,
                        icon: _carregando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 3, color: AppColors.cinza),
                              )
                            : Container(
                                width: 26,
                                height: 26,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                    color: AppColors.creme,
                                    shape: BoxShape.circle),
                                child: const Text('G',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        color: AppColors.cinza)),
                              ),
                        label: Text(
                            _carregando ? 'Entrando...' : 'Entrar com Google'),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Você usa sua conta Google apenas para identificar quem cadastra os pontos. Não guardamos sua senha.',
                        textAlign: TextAlign.center,
                        style: tema.bodyMedium?.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bolha extends StatelessWidget {
  const _Bolha({required this.icone, required this.rotulo});
  final IconData icone;
  final String rotulo;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.creme,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.laranja, width: 2.5),
            ),
            child: Icon(icone, color: AppColors.cinza, size: 28),
          ),
          const SizedBox(height: 6),
          Text(rotulo, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      );
}
