import 'package:flutter/material.dart';

/// Recursos que um ponto de apoio pode oferecer.
enum Recurso {
  agua('Água', Icons.water_drop_rounded),
  comida('Comida', Icons.restaurant_rounded),
  abrigo('Abrigo', Icons.home_rounded);

  const Recurso(this.rotulo, this.icone);
  final String rotulo;
  final IconData icone;
}

/// Para quem é a comida (RN04).
enum AnimalAtendido {
  caes('Cães', Icons.pets_rounded),
  gatos('Gatos', Icons.cruelty_free_rounded),
  ambos('Cães e gatos', Icons.favorite_rounded);

  const AnimalAtendido(this.rotulo, this.icone);
  final String rotulo;
  final IconData icone;
}
