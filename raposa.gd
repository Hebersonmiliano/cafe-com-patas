extends CharacterBody2D
## Controlador de animação quadro a quadro. Pés, braços e cauda estão nos PNGs.
## O relógio vem da partida, mantendo animações paradas durante a pausa.

const DIRECTIONS = ["baixo", "esquerda", "direita", "cima"]
var facing = "baixo"
var current = "parada_baixo"
var clock = 0.0
var serve_remaining = 0.0
var delivered_texture: Texture2D
var delivered_second: Texture2D
@onready var body: AnimatedSprite2D = $Corpo
@onready var item: Sprite2D = $Produto
@onready var item_second: Sprite2D = $Produto2

func _ready() -> void:
	body.speed_scale = 0
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	queue_redraw()

func reset_pose() -> void:
	facing = "baixo"
	serve_remaining = 0
	clock = 0
	current = "parada_baixo"
	body.animation = current
	body.frame = 0
	item.visible = false
	item_second.visible = false
	delivered_second = null

func face_direction(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		return
	if absf(direction.x) > absf(direction.y):
		facing = "direita" if direction.x > 0 else "esquerda"
	else:
		facing = "baixo" if direction.y > 0 else "cima"

func serve(texture: Texture2D,second: Texture2D = null) -> void:
	delivered_texture = texture
	delivered_second = second
	serve_remaining = 0.5
	facing = "baixo"
	set_sequence("entregar")

func set_sequence(value: String) -> void:
	if value != current:
		current = value
		clock = 0
		body.animation = value
		body.frame = 0

func update_pose(delta: float, velocity: Vector2, carrying: bool, preparing: bool, texture: Texture2D,second_texture: Texture2D = null) -> void:
	serve_remaining = maxf(0, serve_remaining - delta)
	if serve_remaining > 0:
		set_sequence("entregar")
	elif preparing:
		set_sequence("preparar")
	else:
		face_direction(velocity)
		var moving = velocity.length_squared() > 0.1
		var prefix = "andar_" if moving else "parada_"
		if carrying:
			prefix = "carregar_" if moving else "segurar_"
		set_sequence(prefix + facing)
	clock += delta
	var count = body.sprite_frames.get_frame_count(current)
	var fps = body.sprite_frames.get_animation_speed(current)
	var index = int(clock * fps)
	body.frame = index % count if body.sprite_frames.get_animation_loop(current) else mini(index, count - 1)
	item.visible = carrying or preparing or serve_remaining > 0
	item.texture = delivered_texture if serve_remaining > 0 else texture
	item_second.texture = delivered_second if serve_remaining>0 else second_texture
	item_second.visible = item.visible and item_second.texture!=null
	var icon_size = 22.0 if item_second.visible else 29.0
	if item.texture:
		var factor = icon_size / maxf(item.texture.get_width(), item.texture.get_height())
		item.scale = Vector2.ONE * factor
	if item_second.texture:
		item_second.scale = Vector2.ONE*icon_size/maxf(item_second.texture.get_width(),item_second.texture.get_height())
	var offset = Vector2(0, 2)
	if facing == "esquerda":
		offset = Vector2(-24, 2)
	elif facing == "direita":
		offset = Vector2(24, 2)
	elif facing == "cima":
		offset = Vector2(0, -2)
	item.z_index = 0
	item_second.z_index = 0
	var behind = facing=="cima" and not preparing and serve_remaining<=0
	move_child(item,0 if behind else get_child_count()-1)
	move_child(item_second,1 if behind else get_child_count()-1)
	if preparing:
		offset = Vector2(sin(clock * 14) * 5, -2)
	if serve_remaining > 0:
		offset = Vector2(0, 4 + sin((0.5 - serve_remaining) * PI / 0.5) * 12)
	item.position = offset+Vector2(-10,-1) if item_second.visible else offset
	item_second.position = offset+Vector2(10,0)

func _draw() -> void:
	draw_set_transform(Vector2(0, 28), 0, Vector2(1, 0.25))
	draw_circle(Vector2.ZERO, 27, Color(0.18, 0.10, 0.06, 0.19))
	draw_set_transform(Vector2.ZERO)
