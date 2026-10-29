# v0.9 — clientes, pedidos compostos e ingredientes

- Três clientes com 16 quadros direcionais por espécie, total de 48 PNGs novos.
- Navegação em grade AStarGrid2D, com obstáculos do mapa e desvio da raposa e de outros clientes. Posições reservadas até a saída; a entrada aguarda espaço livre.
- Ciclo: entrar, caminhar ao lugar reservado, esperar, consumir durante três segundos e sair. Paciência começa a diminuir apenas ao chegar ao ponto de atendimento.
- Expressões de impaciência por movimento e tom do sprite; consumo com produto visível e coração de satisfação.
- Pedidos de um ou dois produtos distintos; marca verde nos itens já entregues. Produto repetido não conta duas vezes. Pagamento e combo só após concluir o pedido inteiro.
- Estoque real por receita: café usa grão e leite; bolo usa uma porção; suco usa duas frutas. Consumo no início do preparo, sem valores negativos.
- Reposição gratuita com R, em três segundos, perto das estações e com bandeja vazia. Essa regra privilegia gerenciamento de tempo e evita bloqueio financeiro.

Testes no Godot 4.7.2: nove ciclos completos, trajetos sem atravessar móveis, reservas exclusivas, chegada simultânea aos três lugares, entrega parcial, repetição rejeitada, pagamento, estoque, reposição, paciência e pausa. Captura da cena com pedidos compostos inspecionada.

Limitações: máximo de três clientes com lugares reservados; não existe uma fila externa ilimitada. Se o jogador bloquear uma passagem, o cliente aguarda e tenta recalcular a rota. As animações de consumo usam movimento do sprite e produto sobreposto, sem novos desenhos de pose sentada.
