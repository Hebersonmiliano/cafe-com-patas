extends Node2D
## Fonte única para posição visual, profundidade e colisão dos móveis.
var solids: Array[Rect2] = []
var furniture: Array[Dictionary] = []
var customer_feet: Array[Vector2] = []
var art: Dictionary
var depth: Node2D
var table_areas: Array[Rect2] = [Rect2(477,388,154,110),Rect2(105,410,158,118),Rect2(900,412,153,111)]
const TABLE_REACH = 72.0
const ACTOR_HALF = Vector2(11, 7)

func build(textures: Dictionary, parent_depth: Node2D) -> void:
	art = textures
	depth = parent_depth
	add_solid("Balcao", Rect2(245,261,680,71))
	add_solid("ParedeNorte", Rect2(20,195,1108,35))
	add_solid("ParedeOeste", Rect2(20,195,34,400))
	add_solid("ParedeLeste", Rect2(1102,195,30,400))
	add_solid("LimiteSul", Rect2(20,580,1112,20))
	# Geladeira recuada: corredor livre entre seus pés e a borda traseira do balcão.
	place("geladeira", Rect2(923,79,98,162), Rect2(934,205,76,30), 235)
	place("mesa_toalha", Rect2(105,410,158,118), Rect2(121,453,127,38), 478)
	place("mesa", Rect2(900,412,153,111), Rect2(911,451,132,37), 476)
	place("mesa_central",table_areas[0],Rect2(489,429,130,35),458)
	# Cadeiras ocupadas: assento alinhado ao destino do cliente, sem obstáculo
	# estático no ponto de chegada. O próprio cliente bloqueia a passagem.
	for seat in [Vector2(650,405),Vector2(270,428),Vector2(1060,425)]:
		place("cadeira",Rect2(seat+Vector2(-28,-38),Vector2(57,89)),Rect2(),seat.y+27)
	var chair_points = [Vector2(112,363),Vector2(95,449),Vector2(886,372),Vector2(462,435)]
	for p in chair_points:
		place("cadeira", Rect2(p,Vector2(57,89)), Rect2(p+Vector2(12,62),Vector2(35,19)), p.y+79)
	for p in [Vector2(35,354),Vector2(33,504),Vector2(1048,227),Vector2(1044,516)]:
		place("planta_grande",Rect2(p,Vector2(75,89)),Rect2(p+Vector2(22,67),Vector2(32,18)),p.y+85)
	place("estante",Rect2(1054,449,65,108),Rect2(1062,527,53,25),552)
	add_solid("Jardineira",Rect2(450,547,248,33))
	for x in [341,790]:
		add_solid("Pilar",Rect2(x,535,20,48))
	var counter_front = Node2D.new()
	counter_front.name = "FrenteBalcao"
	counter_front.position = Vector2(245,332)
	counter_front.draw.connect(func():
		counter_front.draw_rect(Rect2(0,-54,680,60),Color("946344"))
		for x in range(10,669,55):
			counter_front.draw_line(Vector2(x,-46),Vector2(x,2),Color("754e37"),2)
		counter_front.draw_texture_rect(art["texturas/madeira_balcao"],Rect2(0,-71,680,22),false)
		counter_front.draw_rect(Rect2(0,-52,680,5),Color("e7b77c"))
	)
	depth.add_child(counter_front)
	add_counter_sprite(counter_front,"objetos/vitrine",Rect2(638,215,257,101))
	add_counter_sprite(counter_front,"objetos/caixa",Rect2(332,211,85,63))
	add_counter_sprite(counter_front,"objetos/redoma",Rect2(254,192,74,83))
	var planter = Node2D.new()
	planter.name = "FolhasJardineira"
	planter.position = Vector2(574,580)
	for x in range(452,689,37):
		var leaf = Sprite2D.new()
		leaf.texture = art["objetos/planta_pequena"]
		leaf.scale = Vector2.ONE * minf(45.0/leaf.texture.get_width(),51.0/leaf.texture.get_height())
		leaf.position = Vector2(x+22.5,546.5)-planter.position
		planter.add_child(leaf)
	depth.add_child(planter)
	for i in range(table_areas.size()):
		var area = Area2D.new()
		area.name = "AtendimentoMesa"+str(i+1)
		area.position = table_areas[i].get_center()
		area.collision_layer = 0
		area.collision_mask = 1
		var region = RectangleShape2D.new()
		region.size = table_areas[i].size+Vector2.ONE*TABLE_REACH*2
		var collider = CollisionShape2D.new()
		collider.shape = region
		area.add_child(collider)
		add_child(area)

func can_serve_table(seat: int,player_position: Vector2) -> bool:
	if seat<0 or seat>=table_areas.size():
		return false
	return table_areas[seat].grow(TABLE_REACH).has_point(player_position+Vector2(0,28))

func add_counter_sprite(parent: Node2D,key: String,box: Rect2) -> void:
	var sprite = Sprite2D.new()
	sprite.name = key.get_file()
	sprite.texture = art[key]
	sprite.scale = Vector2.ONE*minf(box.size.x/sprite.texture.get_width(),box.size.y/sprite.texture.get_height())
	sprite.position = box.get_center()-parent.position
	parent.add_child(sprite)

func add_solid(label: String, rect: Rect2) -> void:
	solids.append(rect)
	var body = StaticBody2D.new()
	body.name = label + str(solids.size())
	body.position = rect.get_center()
	var collider = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = rect.size
	collider.shape = shape
	body.add_child(collider)
	add_child(body)

func place(key: String, box: Rect2, collision: Rect2, sort_y: float) -> void:
	if collision.has_area():
		add_solid(key, collision)
	var anchor = Node2D.new()
	anchor.name = key + str(furniture.size())
	anchor.position = Vector2(box.get_center().x, sort_y)
	var sprite = Sprite2D.new()
	var tex: Texture2D = art["objetos/"+("mesa" if key=="mesa_central" else key)]
	sprite.texture = tex
	var factor = minf(box.size.x / tex.get_width(), box.size.y / tex.get_height())
	sprite.scale = Vector2.ONE * factor
	sprite.position = box.get_center() - anchor.position
	anchor.add_child(sprite)
	if key == "mesa":
		var plant = Sprite2D.new()
		plant.texture = art["objetos/planta_pequena"]
		plant.scale = Vector2.ONE * minf(39.0/plant.texture.get_width(),49.0/plant.texture.get_height())
		plant.position = Vector2(966.5,426.5)-anchor.position
		anchor.add_child(plant)
	depth.add_child(anchor)
	furniture.append({"name":key,"node":anchor,"rect":collision})

func can_stand(player_position: Vector2, include_customers: bool = true) -> bool:
	var feet = player_position + Vector2(0,28)
	var bounds = Rect2(feet - ACTOR_HALF, ACTOR_HALF * 2)
	for rect in solids:
		if rect.intersects(bounds):
			return false
	if include_customers:
		for pos in customer_feet:
			if Rect2(pos-Vector2(14,8),Vector2(28,16)).intersects(bounds):
				return false
	return true

func clear_path(start: Vector2, target: Vector2) -> bool:
	# Uma interação não atravessa balcão, mesa ou parede.
	for rect in solids:
		if Geometry2D.segment_intersects_segment(start,target,rect.position,Vector2(rect.end.x,rect.position.y)) != null:
			return false
		if Geometry2D.segment_intersects_segment(start,target,Vector2(rect.end.x,rect.position.y),rect.end) != null:
			return false
		if Geometry2D.segment_intersects_segment(start,target,rect.end,Vector2(rect.position.x,rect.end.y)) != null:
			return false
		if Geometry2D.segment_intersects_segment(start,target,Vector2(rect.position.x,rect.end.y),rect.position) != null:
			return false
	return true
