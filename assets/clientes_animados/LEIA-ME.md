# Clientes animados

48 PNGs 128 × 128, 16 por espécie (gato, coelho e capivara). Cada espécie tem quatro direções com quatro quadros de caminhada. Os recursos `frames.tres` incluem as texturas para uso imediato no Godot. Cliente parado usa o sprite original; consumo e impaciência acrescentam movimentos e ícones por código.

Geração: ferramenta integrada de imagens, com o PNG original de cada personagem como referência. Fundo transparente. As folhas foram separadas e alinhadas pela base dos pés com o Image do Godot. As fileiras esquerda/direita do coelho foram corrigidas na extração porque a geração veio em ordem invertida. Os limites das linhas foram medidos pela transparência para preservar orelhas e patas e evitar fragmentos do quadro vizinho.

Prompts finais: production pixel art walking sprite sheet of the exact reference character, strict four columns and four rows, equal cells, sixteen full-body poses with padding and consistent baseline. Row 1 walking down; row 2 walking left; row 3 walking right; row 4 walking up. Alternating steps, preserve colors and accessories, transparent alpha, no labels/scenery/backdrop. Character constraints: calico cat with blue collar and gold bell; white rabbit with pink satchel/scarf and pink inner ears; brown capybara with green scarf. Direções conferidas visualmente antes da integração.
