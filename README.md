# ApoiaPet 🐾
**Encontre pontos. Compartilhe cuidado.**

App Flutter com Firebase (Authentication + Cloud Firestore), tudo no plano gratuito (Spark), sem cartão de crédito e mapa OpenStreetMap.
Projeto da disciplina *Desenvolvimento para plataformas móveis*.

## Conteúdo
| Pasta | O que tem |
|---|---|
| `lib/` | Código Flutter (6 telas, serviços Firebase) |
| `firebase/firestore.rules` | Regras de segurança do Firestore |
| `docs/MODELAGEM.md` + `docs/DER.png` | Modelagem dos dados e diagrama |
| `tool/configurar_plataformas.py` | Ajusta permissões e nome do app no Android/iOS |

## Passo a passo para rodar

### 1. Criar o projeto no Firebase (console.firebase.google.com)
1. **Adicionar projeto** → nome `apoiapet` (Analytics pode ficar desligado).
2. **Authentication** → Começar → aba *Método de login* → ativar **Google** (escolha um e-mail de suporte) → Salvar.
3. **Firestore Database** → Criar banco de dados → modo **produção** → escolha uma região (ex.: `southamerica-east1`).
4. **Não ative o Storage.** O app não usa: a foto é reduzida e guardada dentro do próprio documento do Firestore, então o projeto fica no plano gratuito **Spark** (nunca peça upgrade para Blaze).
5. **Regras:** em *Firestore → Regras*, cole o conteúdo de `firebase/firestore.rules` e **Publicar**.

### 2. Preparar o projeto Flutter
```
flutter create --org br.edu.unidavi --project-name apoiapet --platforms android .
python tool\configurar_plataformas.py
flutter pub get
```

### 3. Conectar o app ao Firebase
Instale o Node.js e depois:
```
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```
No `flutterfire configure`, escolha o projeto `apoiapet` e a plataforma **android**. Ele gera `lib/firebase_options.dart` (substitui o arquivo provisório) e baixa o `google-services.json`.

> Se aparecer erro de `minSdk` ao compilar, abra `android/app/build.gradle` (ou `build.gradle.kts`) e use `minSdk = 23`.

### 4. Rodar
```
flutter analyze
flutter run -d emulator-5554
```
O emulador precisa ter internet e uma imagem **com Google Play** (para o login com Google).

## Protótipo (sem Firebase) — é o padrão
O `lib/main.dart` roda o app completo sem Firebase: login simulado e pontos de exemplo em memória (o cadastro funciona, mas os dados somem ao fechar). Não precisa de conta, `flutterfire` nem `google-services.json`.
```
flutter create --org br.edu.unidavi --project-name apoiapet --platforms android .
python tool\configurar_plataformas.py
flutter pub get
flutter run
```
Para gerar um APK e enviar ao professor (sai em `build/app/outputs/flutter-apk/app-release.apk`):
```
flutter build apk --release
```
**Testar no Chrome (Flutter Web):** adicione a plataforma web ao projeto e rode no navegador:
```
flutter create --platforms web .
flutter pub get
flutter run -d chrome
```
No Chrome, "Tirar foto" abre o seletor de arquivos e a localização pede permissão ao navegador. Se negar, escolha o ponto manualmente no mapa.

A versão com Firebase está em `lib/main_firebase.dart` (`flutter run -t lib/main_firebase.dart`) e exige o passo a passo acima.

## Telas
1. **Login** — Entrar com Google (Firebase Auth); a sessão é mantida ao reabrir o app
2. **Mapa** — marcadores com ícones de água/comida/abrigo, legenda que filtra, localização atual, "Cadastrar ponto"
3. **Detalhes** — foto, endereço, referência, descrição, recursos e animais atendidos
4. **Cadastro** — formulário validado; reduz a foto no aparelho e grava tudo, foto incluída, no Firestore
5. **Seleção de localização** — toque no mapa e confirme (funciona sem GPS)
6. **Perfil** — nome, e-mail, quantidade de pontos, sair e informações da disciplina

## Como testar o Firebase
1. Entre com sua conta Google. No console, em *Authentication → Usuários*, ela deve aparecer, e em *Firestore* deve surgir `usuarios/{uid}`.
2. Cadastre um ponto. Deve aparecer em *Firestore → pontos_apoio*, com a foto no campo `fotoBase64`.
3. Feche e reabra o app: continua logado e o ponto continua no mapa.
4. Rode o app em outro aparelho/emulador com outra conta: o ponto aparece lá também.
5. Teste as regras: no console, em *Firestore → Regras → Simulador de regras*, tente criar um ponto sem recursos e veja a negativa.

## Estrutura do código
- `services/auth_service.dart` e `ponto_repository.dart`: contratos usados pelas telas.
- `app.dart`: o widget raiz do app, compartilhado pelas duas entradas.
- `services/firebase_auth_service.dart` e `firestore_ponto_repository.dart`: implementações Firebase (usadas em `main_firebase.dart`).
- `services/ponto_repository_memoria.dart` e `MockAuthService`: versões em memória, usadas no protótipo (`main.dart`) e no teste automático.

## Sobre a foto e o plano gratuito
- A foto é reduzida no aparelho (máx. 800 px, qualidade 60), o que costuma dar de 50 a 150 KB, e gravada como texto base64 no campo `fotoBase64` do ponto.
- Limite do app e das regras: ~300 KB por foto (o Firestore aceita 1 MiB por documento). Foto maior é recusada com aviso.
- Cota gratuita do Firestore (Spark): 1 GiB guardados, 50 mil leituras/dia e 20 mil gravações/dia. Para um projeto acadêmico, sobra. Como a foto vem junto do ponto, o mapa baixa as fotos de todos os pontos ativos; com centenas de pontos, vale mover a foto para um documento separado.
- Para deixar o projeto sem risco de cobrança, mantenha o plano Spark e não vincule conta de faturamento.

## Observações
- Mapa: tiles públicos do OpenStreetMap, com atribuição. Adequado ao trabalho acadêmico; produção exige respeitar a política de tiles ou usar outro provedor.
- Cores: somente a paleta oficial; o vermelho de erro é o tom auxiliar permitido.
- As regras de segurança e o código Firebase não puderam ser executados no ambiente em que foram escritos; teste conforme a seção acima.
