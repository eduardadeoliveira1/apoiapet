import 'package:flutter_test/flutter_test.dart';

import 'package:apoiapet/app.dart';
import 'package:apoiapet/services/auth_service.dart';
import 'package:apoiapet/services/ponto_repository_memoria.dart';

void main() {
  testWidgets('abre na tela de login com o slogan', (tester) async {
    await tester.pumpWidget(ApoiaPetApp(
      auth: MockAuthService(),
      pontos: PontoRepositoryMemoria(),
    ));

    expect(find.text('ApoiaPet'), findsOneWidget);
    expect(find.text('Encontre pontos. Compartilhe cuidado.'), findsOneWidget);
    expect(find.text('Entrar com Google'), findsOneWidget);
  });
}
