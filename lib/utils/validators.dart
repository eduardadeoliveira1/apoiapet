
class Validators {
  static String? obrigatorio(String? v, String campo, {int min = 1, int? max}) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Informe $campo.';
    if (t.length < min) return 'Escreva um pouco mais ($min caracteres no mínimo).';
    if (max != null && t.length > max) return 'Use no máximo $max caracteres.';
    return null;
  }

  static String? endereco(String? v) =>
      obrigatorio(v, 'o endereço', min: 5, max: 255);
  static String? referencia(String? v) =>
      obrigatorio(v, 'um ponto de referência', min: 3, max: 255);
  static String? descricao(String? v) =>
      obrigatorio(v, 'uma descrição', min: 10, max: 500);
}

String formatarData(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
