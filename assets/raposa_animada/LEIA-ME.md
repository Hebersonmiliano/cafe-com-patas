# Raposa barista animada

48 arquivos PNG 128 × 128 com alpha, organizados em 18 animações. Alguns quadros laterais com bandeja se repetem para manter a direção correta. O recurso `raposa_frames.tres` inclui as texturas e pode ser aberto no painel SpriteFrames do Godot. A cena reutilizável é `res://raposa.tscn`, controlada por `raposa.gd`.

Animações: `parada`, `andar`, `segurar`, `carregar` nas direções `baixo`, `esquerda`, `direita`, `cima`; mais `preparar` e `entregar`. Caminhada: 8 fps; transporte/preparo: 7 fps; entrega: 8 fps sem repetição.

Braços, pernas, cabeça e cauda estão desenhados em cada pose. Trata-se de animação quadro a quadro, sem ossos Skeleton2D ou partes de corpo separadas. Os quadros foram alinhados pelo centro e pela linha dos pés. O produto é um Sprite2D independente, acompanha a bandeja e muda conforme café, bolo ou suco. Durante preparo ele se move com as mãos; durante entrega avança por 0,5 s. A pausa interrompe o relógio das animações.

Abra `previa.html` para comparar todos os movimentos, ou jogue pelo F5 no Godot. O personagem mantém o design aprovado, com pequenas variações de desenho entre quadros gerados.

## Geração

Ferramenta integrada de geração de imagens, usando `assets/personagens/raposa.png` como referência.

Prompt 1: Production animation sprite sheet for this exact orange fox barista, cream muzzle, black paws, white-tipped tail, green apron, gold buttons and paw emblem. Four columns by six rows, transparent background, 24 full-body poses: four walking down, four left, four right, four up, four preparation poses and four hand-over poses. Equal cells, consistent scale and feet baseline, arms and legs alternate, tail sways, no text, props or scenery.

Prompt 2: Same reference character, four columns by five rows, transparent alpha. First row idle down/left/right/up. Remaining rows four-frame walk cycles in each direction carrying an empty wooden tray with both paws. Consistent identity, scale and baseline, no lettering or scene backdrop. The game overlays the product.
