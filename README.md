# Café com Patas

Jogo de cafeteria em pixel art para o Mundo SENAI, desenvolvido no curso técnico de Programação de Jogos Digitais, 2º ano.

**Equipe:** Emilly Lima, Ana Júlia Rodrigues e Prof. Heberson Miliano.

## Executar

Importe `project.godot` no Godot 4.7.2 e pressione F6 na cena principal ou F5 para jogar.

## Como jogar

Atenda oito clientes em três minutos. WASD/setas movem a raposa. E prepara e serve. Café na cafeteira, bolo na vitrine, suco na geladeira. A bandeja aceita dois produtos. E funciona dos lados livres de cada mesa.

R repõe o estoque próximo de uma estação, com bandeja vazia. Q descarta o último item. Esc pausa. M alterna música, F efeitos, +/- volume e L iluminação.

Pedidos simples: gato 44s, coelho 52s, capivara 64s. Pedidos duplos somam 24s. A paciência começa na chegada à mesa.

## Versão 1.3

Bandeja dupla, colisões do balcão e corredor da geladeira corrigidas, três mesas, cadeiras alinhadas aos clientes e quadros de caminhada sem fragmentos dos vizinhos. Consulte `VERSAO-1.2.md`.

Som com mais volume, contrabaixo e pulso suave. **B** alterna graves; **M** liga a música; **+ / −** ajustam volume. As configurações já salvas são preservadas. Consulte `VERSAO-1.3.md`.

## Exportar HTML5

Use `web_tools/exportar-web.ps1 -GodotPath CAMINHO_DO_GODOT`. O jogo utiliza Compatibility, WebGL 2 e exportação sem threads. Sirva os arquivos por HTTP; não abra o HTML diretamente. A versão para navegador utiliza o mesmo código de jogo Godot exportado, com a página em HTML/CSS/JavaScript.

Os testes de regressão estão em `tests/`. Exemplo: `godot --headless --path . --script res://tests/test_bandeja_dupla.gd`.

O motor Godot é distribuído sob licença MIT; a exportação inclui o aviso de licença do motor. Esta licença do motor não concede automaticamente uma licença ao conteúdo do jogo.

