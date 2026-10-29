# v0.6 — camadas, colisões e circulação

Implementada em 29/10/2026. Revisão artística pela equipe pendente.

## Mudanças

- Cena `cafe_map.tscn` com configuração em `cafe_map.gd`: mesas, cadeiras, vasos grandes, geladeira, estante, balcão, jardineira, pilares e limites da sala.
- Formas retangulares de colisão na área de contato com o chão. Folhagens e partes altas permitem sobreposição visual.
- Móveis representados por StaticBody2D; raposa por CharacterBody2D com forma de colisão nos pés. O movimento usa resolução determinística por eixo e subpassos, consultando os mesmos retângulos que geram os corpos estáticos.
- Profundidade Y-sort compartilhada entre raposa, clientes e móveis, com pivôs nos pés. Mesas e cadeiras podem cobrir a parte inferior de quem está atrás.
- Interface em camada superior, inclusive durante pausa e resultado.
- Verificação de linha livre entre personagem e ponto de atendimento: mesas e balcão impedem interação através deles.
- Clientes ocupam posições exclusivas e novos clientes não aparecem sobre a raposa. Clientes permanecem estáticos nesta versão.
- Posição da mesa direita ajustada para manter entrega acessível.

## Verificação

Godot 4.7.2: nove combinações entre produto e posição de cliente com trajetos calculados em uma grade livre de obstáculos, caminhada com colisão, preparo e entrega; teste dos retângulos sólidos; teste de bloqueio de interação; reserva de posições sem sobrepor a raposa. Regressão das 18 animações e do ciclo de partida. Capturas com raposa atrás e à frente da mesa revisadas visualmente.

Não há navegação automática dos clientes ainda: a grade de rotas foi usada apenas nos testes. Próxima etapa: v0.7, interface ilustrada. Iluminação, acabamento e clientes animados permanecem nas etapas seguintes.
