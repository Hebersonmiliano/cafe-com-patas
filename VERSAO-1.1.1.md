# v1.1.1 — balcão, geladeira, mesas e postos de preparo

Correções solicitadas pela equipe após testar a v1.1:

- A colisão do balcão começa na borda traseira do tampo, não apenas na frente de madeira. A raposa inicia no corredor correto e suas patas permanecem fora do tampo.
- Tampo, caixa, redoma e vitrine usam o mesmo grupo de profundidade: cobrem a raposa quando ela está atrás e ficam atrás dela quando está no salão.
- Geladeira recuada e deslocada para a direita, liberando uma passagem contínua diante dela. O ponto dos pés coloca a raposa à frente da geladeira nesse corredor.
- Terceira mesa com duas cadeiras para o cliente central. Colisões e rotas foram recalculadas; cada cliente agora está associado a uma mesa.
- E atende o cliente que está esperando de qualquer lado da mesa, dentro da área de proximidade de 72 pixels. Não é preciso encostar no animal. A colisão sólida do móvel é independente da área de atendimento.
- Café é preparado diante da cafeteira; bolo junto à vitrine; suco diante da geladeira. Rótulos indicam os equipamentos e o alcance de preparo é de 46 pixels, sem sobreposição entre os postos.
- Recortes dos quadros de caminhada da raposa revisados para remover partes da linha vizinha e alinhar corretamente as patas com a sombra.

Verificações: passagem de ida e volta diante da geladeira; bloqueio das patas antes do tampo em seis posições; profundidade dos objetos; 36 entregas (três produtos × quatro lados × três mesas); três postos sem ambiguidade; nove ciclos de clientes e simulação de partida completa. A exportação Web foi refeita com as mesmas correções.
