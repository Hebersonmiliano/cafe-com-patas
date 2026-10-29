# v1.0 — candidata à apresentação

Implementação concluída para revisão da equipe; não equivale a aprovação visual ou teste com visitantes.

## Entregas

- Preserva luz/sombras da v0.8 e clientes/pedidos/estoque da v0.9.
- Efeitos de passos, preparo, produto pronto, entrega parcial/completa, erro, perda de cliente, abertura, reposição e encerramento.
- Pequena melodia original sintetizada, opcional. Sem gravações ou músicas externas.
- F alterna efeitos; M alterna música; + e - ajustam volume. Configurações visíveis durante pausa e guardadas localmente.
- Meta explícita de oito clientes atendidos, com reputação positiva. Resultado distingue um dia de sucesso de expediente encerrado sem atingir a meta.
- Recorde local em moedas, persistido com as preferências. Sem serviços online.
- Tutorial, créditos e roteiro de apresentação.
- Recortes dos sprites de clientes revisados para preservar orelhas/patas e remover partes de quadros vizinhos.

## Verificação realizada

Godot 4.7.2: geração dos streams de áudio, controles de som/música/volume, simulação de uma partida de 180 segundos atingindo a meta, resultado, persistência do recorde e reinício. Regressões de interface, colisões, animações, entrada/consumo/saída, estoque e pedidos compostos. Capturas de jogo, pausa, resultado e clientes caminhando revisadas.

## Pendências de validação

- Sessão com alunos/visitantes sem orientação prévia.
- Ajustar volumes ouvindo nos alto-falantes reais do evento.
- Aprovação artística da equipe: a composição se aproxima da referência, mas ainda há diferenças em detalhes, densidade de decoração e perspectiva.
- Exportar e validar a versão Web, etapa v1.1. Não foi publicado nenhum site nesta entrega.

Os efeitos não são reproduzidos nos testes headless; os streams e controles são validados nesse modo. A reprodução usa AudioStreamPlayer no jogo com janela.
