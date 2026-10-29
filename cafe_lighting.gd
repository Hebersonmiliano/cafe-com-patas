extends Node2D
## Luz cenográfica 2D sem dependência de shaders ou recursos externos.
var game: Node2D
var lamp: Node2D
var enabled_lighting = true

func _ready() -> void:
	lamp = Node2D.new()
	lamp.name = "BrilhoLuminaria"
	lamp.z_index = 1
	lamp.draw.connect(draw_lamp)
	game.add_child.call_deferred(lamp)

func refresh() -> void:
	queue_redraw()
	if is_instance_valid(lamp):
		lamp.queue_redraw()

func toggle() -> void:
	enabled_lighting = not enabled_lighting
	game.depth.modulate = Color(1,0.97,0.91) if enabled_lighting else Color.WHITE
	refresh()

func ellipse(center: Vector2,radius: Vector2,color: Color) -> void:
	var points = PackedVector2Array()
	for i in range(24):
		var angle = TAU*i/24.0
		points.append(center+Vector2(cos(angle),sin(angle))*radius)
	draw_colored_polygon(points,color)

func _draw() -> void:
	if not game or not enabled_lighting:
		return
	# Mancha de sol e travessas da janela. Desenhadas abaixo de móveis e atores.
	draw_colored_polygon(PackedVector2Array([Vector2(77,201),Vector2(77,339),Vector2(445,550),Vector2(604,468)]),Color(1,0.86,0.55,0.17))
	for i in range(3):
		var y = 214+i*41
		draw_colored_polygon(PackedVector2Array([Vector2(78,y),Vector2(78,y+26),Vector2(390+i*40,500+i*12),Vector2(440+i*40,472+i*12)]),Color(1,0.94,0.73,0.17))
	for item in game.cafe_map.furniture:
		var rect: Rect2 = item["rect"]
		var a = Vector2(rect.position.x,rect.end.y-5)
		var b = Vector2(rect.end.x,rect.end.y-5)
		draw_colored_polygon(PackedVector2Array([a,b,b+Vector2(29,16),a+Vector2(29,16)]),Color(0.26,0.14,0.09,0.12))
		ellipse(rect.get_center()+Vector2(0,rect.size.y/2.0),Vector2(rect.size.x*0.48,7),Color(0.23,0.12,0.08,0.12))
	draw_rect(Rect2(245,335,680,9),Color(0.24,0.13,0.08,0.15))
	draw_rect(Rect2(28,187,1096,9),Color(0.24,0.13,0.08,0.12))
	draw_rect(Rect2(28,187,9,401),Color(0.24,0.13,0.08,0.12))

func draw_lamp() -> void:
	if not enabled_lighting:
		return
	for i in range(7,0,-1):
		lamp.draw_circle(Vector2(1088,190),i*12,Color(1,0.78,0.35,0.015))
