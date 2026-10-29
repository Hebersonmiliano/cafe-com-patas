# v0.8 — iluminação e sombras

Luz quente da janela esquerda, faixas de luz no piso, sombras projetadas e de contato dos móveis, sombra dos clientes e brilho suave da luminária. A luz de cenário é desenhada atrás dos atores; a interface mantém suas cores. Tecla L permite comparar com e sem iluminação.

Implementação em `cafe_lighting.gd`, com formas leves compatíveis com o renderizador Compatibility. Não há sombras físicas em tempo real: a direção da luz e as sombras são cenográficas. O desenho dos sprites existentes foi preservado; algumas diferenças de perspectiva e de desenho em relação à referência permanecem para revisão artística.

Captura inspecionada no Godot 4.7.2. Testes de rotas/colisões e interface executados após a integração. Aprovação estética pela equipe e teste na máquina do evento pendentes.
