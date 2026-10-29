# v0.7 — interface ilustrada

Implementada em 29/10/2026. Aprovação visual pela equipe pendente.

- Interface extraída para `cafe_hud.gd`, com painéis de madeira e acabamento em pixels.
- Moedas com ícone de patinha e valor real, inclusive acima de 999.
- Cinco corações correspondentes aos cinco pontos de reputação; perdidos aparecem vazios com contraste reforçado.
- Calendário Dia 1 e relógio da partida, que congela durante pausa.
- Ingredientes com ícones: grãos, leite, fruta e bolo. Sem números fictícios de estoque: ainda não há consumo ou reposição de ingredientes.
- Bandeja com produto atual, total de clientes atendidos e contador de combo.
- Balões de pedidos com imagem, nome e barras verde/amarela/vermelha. Alerta visual quando a paciência está baixa.
- Dicas próximas à raposa para preparar/entregar. Textos principais com pixels de 2 ou 3 pontos na resolução nativa.
- Telas inicial, pausa e resultado com a mesma linguagem visual.

## Fonte e recursos

`pixel_font.gd` contém uma fonte matricial 5 × 7 em código, sem dependência de fonte externa. Letras maiúsculas, números e pontuação são desenhados por pequenos retângulos. Acentos são normalizados para letras básicas na interface pixelada. Os demais ícones são os PNGs gerados anteriormente e documentados em `assets/LEIA-ME.md`.

## Verificação

Teste de 0 a 5 corações; valores de moedas/combos/bandeja/atendimentos; moedas acima de 999; relógio pausado; posição dos balões dentro da tela; reinício. Capturas das telas inicial, jogo, pausa e resultado inspecionadas. Testes anteriores de rotas com colisões, animações e ciclo de partida executados novamente.

Próxima versão: v0.8, iluminação, sombras e consistência artística. Clientes animados, pedidos compostos e estoque consumível continuam planejados na v0.9.
