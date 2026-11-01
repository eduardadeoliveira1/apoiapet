import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../models/ponto_apoio.dart';
import '../models/recurso.dart';
import '../services/app_scope.dart';
import '../services/ponto_repository.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import 'localizacao_screen.dart';

/// Tela 4 — Cadastro de ponto (RF11–RF20, RN01–RN07).
/// Os dados já preenchidos são mantidos quando há erro de validação ou de gravação.
class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key, required this.centroInicial});
  final LatLng centroInicial;

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _endereco = TextEditingController();
  final _referencia = TextEditingController();
  final _descricao = TextEditingController();

  LatLng? _local;
  final Set<Recurso> _recursos = {};
  AnimalAtendido? _animal;
  String? _foto;
  bool _ativo = true;
  bool _salvando = false;

  @override
  void dispose() {
    _endereco.dispose();
    _referencia.dispose();
    _descricao.dispose();
    super.dispose();
  }

  Future<void> _escolherLocal(FormFieldState<LatLng> campo) async {
    final r = await Navigator.of(context).push<LatLng>(MaterialPageRoute(
      builder: (_) => LocalizacaoScreen(
          centroInicial: widget.centroInicial, inicial: _local),
    ));
    if (r != null) {
      setState(() => _local = r);
      campo.didChange(r);
    }
  }

  Future<void> _escolherFoto(FormFieldState<String> campo) async {
    final origem = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.creme,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: const Text('Tirar foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (origem == null) return;
    try {
      final arq = await ImagePicker()
          .pickImage(
              source: origem, maxWidth: 800, maxHeight: 800, imageQuality: 60);
      if (arq != null) {
        setState(() => _foto = arq.path);
        campo.didChange(arq.path);
      }
    } catch (_) {
      _aviso('Não foi possível abrir a câmera ou a galeria.');
    }
  }

  void _aviso(String t) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(t)));

  Future<void> _salvar() async {
    // RF04/RN01: só chega aqui autenticado (tela exige login), mas conferimos.
    final scope = AppScope.of(context);
    final usuario = scope.auth.usuario;
    if (usuario == null) {
      _aviso('Entre com sua conta Google para cadastrar um ponto.');
      return;
    }
    if (!_formKey.currentState!.validate()) {
      _aviso('Revise os campos destacados.');
      return;
    }

    setState(() => _salvando = true);
    try {
      final salvo = await scope.pontos.cadastrar(NovoPonto(
        usuarioId: usuario.id,
        cadastradoPor: usuario.nome,
        latitude: _local!.latitude,
        longitude: _local!.longitude,
        endereco: _endereco.text.trim(),
        referencia: _referencia.text.trim(),
        descricao: _descricao.text.trim(),
        possuiAgua: _recursos.contains(Recurso.agua),
        possuiComida: _recursos.contains(Recurso.comida),
        possuiAbrigo: _recursos.contains(Recurso.abrigo),
        atendeCaes: _animal == AnimalAtendido.caes ||
            _animal == AnimalAtendido.ambos,
        atendeGatos: _animal == AnimalAtendido.gatos ||
            _animal == AnimalAtendido.ambos,
        pontoAtivo: _ativo,
        fotoLocal: _foto!,
      ));
      if (mounted) Navigator.of(context).pop<PontoApoio>(salvo);
    } on RepositorioException catch (e) {
      _aviso(e.mensagem); // dados do formulário continuam preenchidos
    } catch (_) {
      _aviso('Algo deu errado ao salvar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar ponto')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Text('Conte onde fica o ponto e o que ele oferece.',
                  style: tema.bodyLarge),
              const SizedBox(height: 20),

              // 1. Localização (RN02)
              const _Titulo('1. Localização no mapa'),
              FormField<LatLng>(
                initialValue: _local,
                validator: (_) =>
                    _local == null ? 'Escolha a localização no mapa.' : null,
                builder: (campo) => _CartaoCampo(
                  erro: campo.errorText,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.location_on_rounded,
                        color: AppColors.laranja, size: 32),
                    title: Text(
                      _local == null
                          ? 'Nenhuma localização escolhida'
                          : '${_local!.latitude.toStringAsFixed(5)}, ${_local!.longitude.toStringAsFixed(5)}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    trailing: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size(110, 48)),
                      onPressed: () => _escolherLocal(campo),
                      child: Text(_local == null ? 'Escolher' : 'Alterar'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // 2. Endereço
              const _Titulo('2. Endereço e referência'),
              TextFormField(
                controller: _endereco,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                    labelText: 'Endereço',
                    hintText: 'Rua, número, bairro',
                    prefixIcon: Icon(Icons.place_outlined)),
                validator: Validators.endereco,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _referencia,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                    labelText: 'Ponto de referência',
                    hintText: 'Ex.: ao lado da padaria',
                    prefixIcon: Icon(Icons.flag_outlined)),
                validator: Validators.referencia,
              ),
              const SizedBox(height: 22),

              // 3. Recursos (RN03)
              const _Titulo('3. O que o ponto oferece?'),
              FormField<Set<Recurso>>(
                initialValue: _recursos,
                validator: (_) => _recursos.isEmpty
                    ? 'Selecione pelo menos um recurso.'
                    : null,
                builder: (campo) => _CartaoCampo(
                  erro: campo.errorText,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      for (final r in Recurso.values)
                        FilterChip(
                          selected: _recursos.contains(r),
                          showCheckmark: false,
                          avatar: Icon(r.icone,
                              size: 22, color: AppColors.cinza),
                          label: Text(r.rotulo,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                          selectedColor: AppColors.amarelo,
                          backgroundColor: AppColors.creme,
                          side: BorderSide(
                              color: _recursos.contains(r)
                                  ? AppColors.laranja
                                  : AppColors.cinza.withAlpha(90),
                              width: 1.8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 10),
                          onSelected: (_) {
                            setState(() {
                              _recursos.contains(r)
                                  ? _recursos.remove(r)
                                  : _recursos.add(r);
                              // RN05: sem comida, o tipo de animal não se aplica
                              if (!_recursos.contains(Recurso.comida)) {
                                _animal = null;
                              }
                            });
                            campo.didChange(_recursos);
                          },
                        ),
                    ],
                  ),
                ),
              ),

              // 4. Animais (RN04) — só aparece quando há comida
              if (_recursos.contains(Recurso.comida)) ...[
                const SizedBox(height: 22),
                const _Titulo('4. A comida é para quem?'),
                FormField<AnimalAtendido>(
                  initialValue: _animal,
                  validator: (_) => _animal == null
                      ? 'Informe se a comida é para cães, gatos ou ambos.'
                      : null,
                  builder: (campo) => _CartaoCampo(
                    erro: campo.errorText,
                    child: SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<AnimalAtendido>(
                        emptySelectionAllowed: true,
                        showSelectedIcon: false,
                        selected: {if (_animal != null) _animal!},
                        onSelectionChanged: (s) {
                          setState(() => _animal = s.isEmpty ? null : s.first);
                          campo.didChange(_animal);
                        },
                        style: SegmentedButton.styleFrom(
                          foregroundColor: AppColors.cinza,
                          selectedBackgroundColor: AppColors.amarelo,
                          selectedForegroundColor: AppColors.cinza,
                          minimumSize: const Size.fromHeight(52),
                          side: BorderSide(
                              color: AppColors.cinza.withAlpha(90),
                              width: 1.8),
                        ),
                        segments: [
                          for (final a in AnimalAtendido.values)
                            ButtonSegment(
                              value: a,
                              icon: Icon(a.icone, size: 20),
                              label: Text(
                                  a == AnimalAtendido.ambos ? 'Ambos' : a.rotulo),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 22),

              // 5. Descrição
              _Titulo('${_recursos.contains(Recurso.comida) ? 5 : 4}. Descrição'),
              TextFormField(
                controller: _descricao,
                minLines: 3,
                maxLines: 5,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    labelText: 'Descreva o ponto',
                    hintText:
                        'Ex.: pote de água trocado todo dia pela manhã',
                    alignLabelWithHint: true),
                validator: Validators.descricao,
              ),
              const SizedBox(height: 10),

              // 6. Foto
              _Titulo('${_recursos.contains(Recurso.comida) ? 6 : 5}. Fotografia'),
              FormField<String>(
                initialValue: _foto,
                validator: (_) =>
                    _foto == null ? 'Adicione uma foto do local.' : null,
                builder: (campo) => _CartaoCampo(
                  erro: campo.errorText,
                  child: Column(
                    children: [
                      if (_foto != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: AspectRatio(
                            aspectRatio: 16 / 10,
                            // No Chrome o image_picker devolve um endereço blob:, não um arquivo.
                            child: kIsWeb
                                ? Image.network(_foto!, fit: BoxFit.cover)
                                : Image.file(File(_foto!), fit: BoxFit.cover),
                          ),
                        ),
                      if (_foto != null) const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () => _escolherFoto(campo),
                        icon: Icon(_foto == null
                            ? Icons.add_a_photo_rounded
                            : Icons.swap_horiz_rounded),
                        label: Text(_foto == null
                            ? 'Adicionar foto'
                            : 'Trocar foto'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Ativo ou não (fluxo B)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _ativo,
                onChanged: (v) => setState(() => _ativo = v),
                title: const Text('Ponto ativo',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(_ativo
                    ? 'Aparece no mapa para todos.'
                    : 'Fica salvo, mas oculto no mapa.'),
              ),
              const SizedBox(height: 18),

              FilledButton.icon(
                onPressed: _salvando ? null : _salvar,
                icon: _salvando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 3, color: AppColors.cinza))
                    : const Icon(Icons.check_circle_rounded),
                label: Text(_salvando ? 'Salvando...' : 'Salvar ponto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);
  final String texto;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(texto, style: Theme.of(context).textTheme.titleMedium),
      );
}

/// Moldura com mensagem de erro, usada pelos campos que não são de texto.
class _CartaoCampo extends StatelessWidget {
  const _CartaoCampo({required this.child, this.erro});
  final Widget child;
  final String? erro;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: erro == null
                      ? AppColors.cinza.withAlpha(60)
                      : AppColors.erro,
                  width: erro == null ? 1.5 : 2),
            ),
            child: child,
          ),
          if (erro != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 0, 0),
              child: Text(erro!,
                  style: const TextStyle(
                      color: AppColors.erro, fontWeight: FontWeight.w600)),
            ),
        ],
      );
}
