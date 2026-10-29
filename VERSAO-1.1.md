# v1.1 — exportação Web

Implementada e verificada localmente. Publicação pública pendente de definição da hospedagem.

- Preset Web em `export_presets.cfg`, sem threads, renderização Compatibility.
- Shell HTML próprio com botão Jogar, progresso de download, mensagens de erro, instruções, créditos e tela cheia.
- Canvas 16:9 adaptado à largura disponível. Controle por teclado; sem toque.
- Áudio em modo Stream no navegador para preservar os sons gerados pelo código.
- Pausa ao perder o foco da aplicação.
- Servidor local Python com tipos MIME para WASM/JS/PCK.
- Ferramenta de reexportação em `web_tools/exportar-web.ps1`.

Os modelos oficiais da mesma versão do Godot foram usados. Para reexportar em outro computador, instale os modelos Web 4.7.2 no Godot e execute o script passando `-GodotPath` com o executável do editor. O preset grava em uma pasta irmã `cafe-com-patas-web`.

Verificação no navegador integrado: abertura, carregamento, Enter, movimento, preparo, estoque/bandeja, música, pausa e retomada. Console sem erros/avisos na amostra inspecionada. A revisão auditiva no equipamento do evento e a publicação HTTPS ainda estão pendentes. Não foi executada uma partida completa dentro do navegador; a partida completa foi testada na versão nativa.

Fontes de configuração: [exportação Web oficial](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html) e [tipos de reprodução de áudio](https://docs.godotengine.org/en/stable/classes/class_audioserver.html#enum-audioserver-playbacktype).
