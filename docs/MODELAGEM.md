# ApoiaPet — Modelagem de dados (Firebase)

| Serviço | Para quê |
|---|---|
| **Authentication** | Login com Google e sessão do usuário (RF01–RF04) |
| **Cloud Firestore** | Dados dos usuários, dos pontos de apoio e das fotos (base64) |

## Coleção `usuarios` (ID do documento = UID do Firebase Auth)
| Campo | Tipo | Obrig. | Observação |
|---|---|---|---|
| nome | string | sim | Nome da conta Google |
| email | string | sim | E-mail da conta |
| dataCadastro | timestamp | sim | Gravada pelo servidor no primeiro login |
| ultimoAcesso | timestamp | sim | Atualizada a cada login |

Nenhuma senha é armazenada.

## Coleção `pontos_apoio` (ID do documento gerado pelo Firestore — RN07)
| Campo | Tipo | Obrig. | Observação |
|---|---|---|---|
| usuarioId | string | sim | UID de quem cadastrou (deve ser o usuário logado) |
| cadastradoPor | string | não | Nome exibido nos detalhes |
| latitude | number | sim | −90 a 90 (RN02) |
| longitude | number | sim | −180 a 180 (RN02) |
| endereco | string | sim | 1 a 255 caracteres |
| referencia | string | sim | 1 a 255 caracteres |
| descricao | string | sim | 1 a 500 caracteres |
| possuiAgua / possuiComida / possuiAbrigo | boolean | sim | Pelo menos um verdadeiro (RN03) |
| atendeCaes / atendeGatos | boolean | sim | Com comida, ao menos um verdadeiro (RN04); sem comida, ambos falsos (RN05) |
| pontoAtivo | boolean | sim | Padrão `true`; `false` oculta o ponto do mapa |
| fotoBase64 | string | sim | Foto reduzida, em base64, de 1 a 400.000 caracteres (~300 KB) (RN06) |
| dataCadastro | timestamp | sim | Gravada pelo servidor |

## Fotos
Não há Storage. A foto fica no campo `fotoBase64` do próprio ponto, reduzida no aparelho (800 px, qualidade 60). O limite de 1 MiB por documento do Firestore é respeitado com folga.

## Onde cada regra de negócio é garantida
| Regra | App (formulário) | Firestore Rules |
|---|---|---|
| RN01 só autenticado cadastra | tela exige login | `request.auth != null` e `usuarioId == auth.uid` |
| RN02 localização válida | campo obrigatório | faixa de latitude/longitude |
| RN03 ao menos um recurso | validação do formulário | `possuiAgua \|\| possuiComida \|\| possuiAbrigo` |
| RN04 comida exige cães/gatos | campo aparece e é obrigatório | `!possuiComida \|\| atendeCaes \|\| atendeGatos` |
| RN05 sem comida, animais não valem | campo some e é zerado | `possuiComida \|\| (!atendeCaes && !atendeGatos)` |
| RN06 foto vinculada ao ponto | foto obrigatória, gravada no próprio ponto | `fotoBase64` obrigatório e limitado |
| RN07 id único | — | id automático do Firestore |
| RN08 dados persistem | — | gravação no Firestore |
| RN09 GPS opcional | seleção manual no mapa | — |

As regras completas estão em `firebase/firestore.rules`. Elas também bloqueiam edição e exclusão de pontos.

## Sequência de gravação de um ponto
1. Valida o formulário.
2. Cria o id do ponto.
3. Lê a foto já reduzida e converte para base64.
4. Grava o documento no Firestore, foto incluída, em uma única operação.
5. O mapa atualiza sozinho (o app escuta a coleção em tempo real).

Como foto e dados vão no mesmo documento, não existe foto órfã nem etapa de limpeza.

## Consultas usadas
- Mapa: `pontos_apoio` onde `pontoAtivo == true` (índice automático, sem configuração).
- Perfil: contagem de `pontos_apoio` onde `usuarioId == uid`.
