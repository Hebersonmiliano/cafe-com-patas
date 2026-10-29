# Café com Patas — protótipo Godot

Versão atual: **v1.1.1 — correções de circulação e atendimento**. Patas fora do tampo, objetos na profundidade correta, passagem diante da geladeira, três mesas com cadeiras e E por qualquer lado da mesa ocupada. Café na cafeteira, bolo na vitrine e suco na geladeira, com alcance curto e rótulos nos equipamentos. A exportação Web foi atualizada; ainda não há publicação pública.

O painel inferior mostra o estoque real de grãos, leite, fruta e bolo. O calendário indica Dia 1; não há progressão de dias ainda. L alterna a iluminação para comparação.

Projeto educacional de Emilly Lima, Ana Júlia Rodrigues e prof. Heberson Miliano para o Mundo SENAI.

## Abrir e jogar

1. Use a edição padrão do Godot com GDScript. Esta versão foi verificada no Godot 4.7.2.
2. No gerenciador de projetos, escolha **Importar** e selecione `project.godot` desta pasta.
3. Abra o projeto e pressione **F6** na cena principal ou **F5** para jogar.
4. Na tela inicial, pressione Enter.

Controles: WASD/setas para mover; E/espaço para preparar/entregar; R para repor ingredientes; Q para descartar; Esc para pausar; F para ligar/desligar efeitos; M para música; + e - para volume; L para comparar iluminação.

Leia o pedido dos clientes, caminhe até a cafeteira para café, a vitrine para bolo ou a geladeira para suco e aperte E. Aguarde o preparo, saia pela lateral e aproxime-se de qualquer lado da mesa ocupada para entregar com E. Alguns pedidos exigem dois produtos diferentes: entregue ambos para receber o pagamento. Ingredientes são consumidos no preparo; R repõe após três segundos, perto dos equipamentos e com a bandeja vazia. Entregas completas consecutivas aumentam o bônus. Gatos esperam 32 segundos, coelhos 40 e capivaras 58, contados após chegar ao atendimento.

## Conteúdo

- Movimento, três estações e três espécies com paciência diferente.
- Pedidos aleatórios, preparo com duração, bandeja e validação de entrega.
- Pontuação, bônus de combo, reputação, pausa e reinício.
- Arte em PNG na pasta `assets`, baseada na referência visual aprovada, desenhada por `main.gd`.
- Receitas compartilháveis em `recipes.json`, preparadas para uma futura implementação JavaScript.

A pasta `assets` inclui os 54 sprites/texturas iniciais, 48 PNGs da raposa e 48 dos clientes: 150 PNGs no total. A raposa tem 18 animações e os clientes têm quatro ciclos direcionais por espécie. Veja as notas em `assets/raposa_animada` e `assets/clientes_animados`. Parte da decoração disponível no catálogo não foi aplicada ao cenário.

Efeitos ficam ligados e música desligada por padrão. Preferências de áudio e recorde ficam no arquivo local `user://cafe_com_patas.cfg`, fora do projeto. Não há envio de dados ou ranking online. Os sons e a pequena melodia são sintetizados pelo código de `cafe_audio.gd`, sem arquivos de áudio externos.

Consulte `APRESENTACAO.md` para um roteiro do Mundo SENAI. A v1.0 é uma candidata funcional: a aprovação artística, testes com visitantes e validação na máquina do evento continuam pendentes. O visual aproxima a referência, sem reproduzi-la pixel a pixel.

## Testes incluídos

Com o Godot no terminal, dentro desta pasta: `godot --headless --path . --script tests/test_v10.gd`. Os demais testes cobrem navegação/ciclos dos clientes (`test_v09.gd`), colisões (`test_v06.gd`), interface (`test_hud.gd`), raposa (`test_fox.gd`) e ciclo básico (`test_cafe.gd`). Em modo headless o áudio é construído e validado, mas não reproduzido.

## Exportar para Web

O projeto usa Compatibility. No Godot, instale os modelos de exportação em Editor > Gerenciar modelos de exportação. Em Projeto > Exportar, adicione Web e exporte como `index.html` em uma pasta própria. Para hospedagens simples, comece com suporte a threads desativado. Publique todos os arquivos gerados juntos em um servidor web; não abra apenas o HTML pelo explorador.

O preset Web já está incluído nesta versão, assim como `web_shell.html`. Para repetir a exportação no Windows, use `web_tools/exportar-web.ps1 -GodotPath CAMINHO_DO_GODOT`. Veja `VERSAO-1.1.md`. A pasta exportada inclui `serve.py` para o teste por `http://127.0.0.1:8765/`.

Essa exportação usa o runtime Godot no navegador. Uma versão independente em HTML/CSS/JavaScript requer implementar a lógica nessa tecnologia; regras, receitas e recursos visuais podem ser reaproveitados.
