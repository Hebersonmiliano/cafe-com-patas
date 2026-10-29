extends Node2D
var body: Sprite2D
var product: Sprite2D
var emotion: Sprite2D
var frames: SpriteFrames
var species = -1
var clock = 0.0
var facing = "baixo"
func setup(texture: Texture2D) -> void:
	body = Sprite2D.new()
	body.texture = texture
	add_child(body)
	product = Sprite2D.new()
	product.visible = false
	product.position = Vector2(9,-20)
	add_child(product)
	emotion = Sprite2D.new()
	emotion.visible = false
	emotion.position = Vector2(0,-103)
	add_child(emotion)
	queue_redraw()

func update_visual(c: Dictionary,game: Node2D,delta: float) -> void:
	clock += delta
	if species!=c["species"]:
		species = c["species"]
		frames = load("res://assets/clientes_animados/"+["gato","coelho","capivara"][species]+"/frames.tres")
	position = c.get("pos",game.SEATS[c["seat"]])+Vector2(0,28)
	var velocity: Vector2 = c.get("velocity",Vector2.ZERO)
	var moving = velocity.length_squared()>0.1
	if moving:
		if absf(velocity.x)>absf(velocity.y):
			facing = "direita" if velocity.x>0 else "esquerda"
		else:
			facing = "baixo" if velocity.y>0 else "cima"
		body.texture = frames.get_frame_texture(facing,int(clock*7)%4)
		body.scale = Vector2.ONE*0.79
		body.position = Vector2(0,-45.82)
	else:
		body.texture = game.art["personagens/"+["gato","coelho","capivara"][species]]
		body.scale = Vector2.ONE*minf(86.0/body.texture.get_width(),94.0/body.texture.get_height())
		body.position = Vector2(0,-40)
		if c.get("state","") in ["waiting","consuming"]:
			body.scale *= 0.82
			body.position.y = -51
	var consuming = c.get("state","")=="consuming"
	var urgent = c.get("state","")=="waiting" and c["left"]/c["total"]<0.25
	body.rotation = sin(clock*4)*0.035 if consuming else sin(clock*12)*0.025 if urgent else 0.0
	body.modulate = Color(1,0.91,0.88) if urgent else Color.WHITE
	product.visible = consuming
	if consuming:
		product.texture = game.art["produtos_ui/"+["cafe","bolo","suco"][c["items"][0]]]
		product.scale = Vector2.ONE*27.0/maxf(product.texture.get_width(),product.texture.get_height())
	emotion.visible = consuming
	emotion.texture = game.art["produtos_ui/coracao"]
	emotion.scale = Vector2.ONE*18.0/maxf(emotion.texture.get_width(),emotion.texture.get_height())

func _draw() -> void:
	draw_set_transform(Vector2.ZERO,0,Vector2(1,0.25))
	draw_circle(Vector2.ZERO,24,Color(0.20,0.11,0.07,0.18))
	draw_set_transform(Vector2.ZERO)
