# Site Café com Patas

Site e guia: https://cafe-com-patas-mundo-senai.hebersonmiliano.chatgpt.site

O site publicado é privado para revisão. A pasta site contém HTML/CSS, capturas reais e a página do jogo. Os arquivos grandes do motor são gerados pelo Godot e não fazem parte do código-fonte.

Para reconstruir: exporte o projeto com web_tools/exportar-web.ps1 e copie index.js, index.pck, os scripts worklet e ícones da pasta Web para site/jogar/. Comprima index.wasm em gzip como site/jogar/index.wasm.gz (sem o arquivo wasm original). A página index.html descomprime o motor no navegador. Sirva site/ por HTTP. Requer navegador com DecompressionStream e WebGL 2.

Os retratos de personagens em site/assets são os sprites do próprio jogo. As capturas foram feitas com estados preparados para explicar a jogabilidade; não são fotografias dos alunos.
