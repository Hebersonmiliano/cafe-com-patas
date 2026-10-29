# Sprites da referência Café com Patas

54 PNGs individuais iniciais: 4 personagens, 30 objetos, 16 produtos/ícones e 4 texturas. `galeria.html` permite visualizar o catálogo sem servidor. `catalogo.json` contém nomes, grupos e dimensões de cada arquivo. A pasta `raposa_animada` acrescenta 48 PNGs e 18 animações; abra `raposa_animada/previa.html` para vê-las.

Os sprites foram criados pela ferramenta integrada de geração de imagens com a imagem `prototipo-cafe-com-patas.png` como referência. Depois as folhas foram separadas em PNGs por regiões usando Image do Godot. Os personagens, produtos e parte dos móveis já estão aplicados em `main.gd`.

Direção de arte: pixel art acolhedora, contornos marrons, tons de caramelo, creme, verde e rosa; vista elevada compatível com a referência. A geração mantém a identidade visual, mas não garante reprodução pixel a pixel. Os clientes são estáticos; a raposa possui caminhada e ações na pasta `raposa_animada`. As texturas são materiais visuais, não um tileset com regras de autotile.

## Prompts finais usados (ferramenta integrada)

Personagens: Create a production sprite atlas based strictly on the four animal character designs in the reference Café com Patas image. Transparent background. One horizontal row of four equal cells. Calico cat with blue collar; white rabbit with pink satchel; brown capybara wearing green scarf; orange fox barista with green apron. Same baseline, full body, three-quarter front view, warm pixel art, transparent padding, no text or furniture.

Objetos: Create a game asset atlas of every environmental object in the reference, matching warm detailed pixel art and elevated view. Thirty isolated assets: counter, pastry display, espresso machine, grinder, refrigerator, register, two tables, chair, two rugs, gate, four plant/flower arrangements, lamp, bookshelf, sign, chalkboard, paw artwork, shelf, cake dome, jars, milk bottle, sticky notes, cups, pitcher and plate. Transparent alpha, no characters. Refinement: remove backdrop, preserve objects, separate cells, preserve pixel details.

Produtos/UI: Produce isolated transparent pixel art sprites matching the café reference: cappuccino, cake slice, strawberry juice, strawberry, beans, milk, croissant, muffin, pink cupcake, white cupcake, cookie, tart, paw coin, heart, empty heart and speech bubble. Brown outlines, warm palette, no lettering.

Texturas: Pixel art material atlas with cream/peach diagonal checker floor, brown wood wall, caramel countertop wood and cream plaster wall. Orthographic materials, warm palette, no objects or text.
