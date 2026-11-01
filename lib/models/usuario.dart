class Usuario {
  const Usuario({required this.id, required this.nome, required this.email});

  final String id;
  final String nome;
  final String email;

  String get iniciais {
    final partes = nome.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty || partes.first.isEmpty) return '?';
    if (partes.length == 1) return partes.first[0].toUpperCase();
    return (partes.first[0] + partes.last[0]).toUpperCase();
  }
}
