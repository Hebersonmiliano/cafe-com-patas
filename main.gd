extends Node2D
## Café com Patas: sprites baseados na referência visual aprovada.

const CREAM = Color("fff0d2")
const INK = Color("493127")
const GREEN = Color("578b65")
const RELEASE = "1.3"
const SERVICE_GOAL = 8
const STATIONS = [Vector2(725, 220), Vector2(842, 220), Vector2(974, 220)]
const PREP_REACH = 46.0
const SEATS = [Vector2(650, 405), Vector2(270, 428), Vector2(1060, 425)]
const INITIAL_STOCK = [12,12,16,10]
const SPECIES = ["Gato", "Coelho", "Capivara"]
const PATIENCE = [44.0, 52.0, 64.0]
const TRAY_CAPACITY = 2
var recipes: Array = []
var player = Vector2(530, 220)
var customers: Array = []
var coins = 0
var served = 0
var missed = 0
var combo = 0
var reputation = 5
var remaining = 180.0
var tray: Array[int] = []
var held: int:
	get:
		return tray[0] if not tray.is_empty() else -1
	set(value):
		tray.clear()
		if value>=0:
			tray.append(value)
var preparing = -1
var prep_left = 0.0
var spawn_left = 3.0
var mode = "title"
var message = ""
var message_left = 0.0
var elapsed = 0.0
var font: Font
var art: Dictionary = {}
var fox: Node2D
var movement = Vector2.ZERO
var depth: Node2D
var fox_anchor: Node2D
var cafe_map: Node2D
var customer_nodes: Dictionary = {}
var hud: Node2D
var painter: Node2D
var lighting: Node2D
var flow: RefCounted
var stock: Array = INITIAL_STOCK.duplicate()
var restock_left = 0.0
var sounds: Node
var footstep_left = 0.0
var finished_round = false

func _ready() -> void:
	font = ThemeDB.fallback_font
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var catalog = JSON.parse_string(FileAccess.get_file_as_string("res://assets/catalogo.json"))
	for entry in catalog:
		var path = "res://assets/%s/%s.png" % [entry["group"], entry["name"]]
		art[entry["group"] + "/" + entry["name"]] = load(path)
	var data = JSON.parse_string(FileAccess.get_file_as_string("res://recipes.json"))
	if data is Array:
		recipes = data
	depth = Node2D.new()
	depth.name = "Profundidade"
	depth.y_sort_enabled = true
	add_child(depth)
	cafe_map = preload("res://cafe_map.tscn").instantiate()
	add_child(cafe_map)
	cafe_map.build(art, depth)
	flow = preload("res://customer_flow.gd").new()
	flow.setup(self)
	sounds = Node.new()
	sounds.set_script(preload("res://cafe_audio.gd"))
	add_child(sounds)
	lighting = Node2D.new()
	lighting.set_script(preload("res://cafe_lighting.gd"))
	lighting.game = self
	add_child(lighting)
	move_child(lighting,0)
	depth.modulate = Color(1,0.97,0.91)
	fox_anchor = Node2D.new()
	fox_anchor.name = "PesRaposa"
	depth.add_child(fox_anchor)
	fox = preload("res://raposa.tscn").instantiate()
	fox_anchor.add_child(fox)
	fox.position = Vector2(0,-28)
	fox_anchor.position = player + Vector2(0,28)
	hud = Node2D.new()
	hud.name = "Interface"
	hud.z_index = 10
	hud.set_script(preload("res://cafe_hud.gd"))
	hud.game = self
	add_child(hud)
	queue_redraw()

func restart() -> void:
	player = Vector2(530, 220)
	customers.clear()
	sync_customers()
	coins = 0
	served = 0
	missed = 0
	combo = 0
	reputation = 5
	remaining = 180.0
	held = -1
	preparing = -1
	stock = INITIAL_STOCK.duplicate()
	restock_left = 0
	finished_round = false
	footstep_left = 0
	if fox:
		fox.reset_pose()
		fox_anchor.position = player + Vector2(0,28)
	movement = Vector2.ZERO
	spawn_left = 7.0
	mode = "play"
	sounds.update_state(mode)
	sounds.play("open")
	spawn_customer()
	toast("A cafeteria abriu! Vá ao balcão para preparar um pedido.")

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if sounds.settings_key(event.keycode):
		sounds.update_state(mode)
		hud.queue_redraw()
		return
	if event.keycode == KEY_ENTER and (mode == "title" or mode == "end"):
		restart()
	elif event.keycode == KEY_L:
		lighting.toggle()
	elif event.keycode == KEY_ESCAPE:
		if mode == "play":
			mode = "pause"
		elif mode == "pause":
			mode = "play"
	elif mode == "play":
		if event.keycode == KEY_E or event.keycode == KEY_SPACE:
			interact()
		elif event.keycode == KEY_Q and preparing == -1:
			if not tray.is_empty():
				var discarded: int = tray.pop_back()
				toast("Descartado: "+str(recipes[discarded]["name"])+". Bandeja %d/2." % tray.size())
		elif event.keycode == KEY_R:
			start_restock()
	queue_redraw()

func _notification(what: int) -> void:
	if what==NOTIFICATION_APPLICATION_FOCUS_OUT and mode=="play":
		mode = "pause"
		if sounds:
			sounds.update_state(mode)
		if hud:
			hud.queue_redraw()

func _process(delta: float) -> void:
	sounds.update_state(mode)
	fox.visible = mode == "play"
	if mode != "play":
		return
	movement = Vector2.ZERO
	elapsed += delta
	remaining = maxf(0.0, remaining - delta)
	message_left = maxf(0.0, message_left - delta)
	if restock_left>0:
		restock_left = maxf(0,restock_left-delta)
		if restock_left==0:
			stock = INITIAL_STOCK.duplicate()
			sounds.play("restock")
			toast("Ingredientes repostos. Bom atendimento!")
	elif preparing >= 0:
		prep_left -= delta
		if prep_left <= 0:
			var prepared = preparing
			tray.append(prepared)
			preparing = -1
			sounds.play("ready")
			toast("%s pronto! Bandeja %d/2. Prepare outro ou entregue com E." % [recipes[prepared]["name"],tray.size()])
	elif fox.serve_remaining <= 0:
		var direction = Vector2.ZERO
		if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
			direction.x -= 1
		if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
			direction.x += 1
		if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
			direction.y -= 1
		if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
			direction.y += 1
		var previous = player
		move_player(direction.normalized() * 235.0 * delta)
		movement = player - previous
	footstep_left = maxf(0,footstep_left-delta)
	if movement.length_squared()>0.1 and footstep_left==0:
		sounds.play("step")
		footstep_left = 0.28
	fox_anchor.position = player + Vector2(0,28)
	var displayed_product = held if held>=0 else preparing
	var product_texture: Texture2D = null
	var second_texture: Texture2D = null
	if displayed_product >= 0:
		product_texture = art["produtos_ui/" + ["cafe", "bolo", "suco"][displayed_product]]
	var second_product = tray[1] if tray.size()>1 else preparing if tray.size()==1 and preparing>=0 else -1
	if second_product>=0:
		second_texture = art["produtos_ui/"+["cafe","bolo","suco"][second_product]]
	fox.update_pose(delta, movement, held >= 0, preparing >= 0 or restock_left>0, product_texture,second_texture)
	spawn_left -= delta
	if spawn_left <= 0:
		spawn_customer()
		spawn_left = arrival_interval()
	flow.update(delta)
	reputation = maxi(0,reputation)
	if remaining <= 0 or reputation <= 0:
		finish_round()
	sync_customers(delta)
	hud.queue_redraw()
	queue_redraw()

func move_player(offset: Vector2) -> void:
	# Subpassos e resolução por eixo impedem atravessar móveis e permitem deslizar.
	var steps = maxi(1, int(ceil(offset.length() / 8.0)))
	var step = offset / steps
	for n in range(steps):
		var proposed = player + Vector2(step.x, 0)
		if cafe_map.can_stand(proposed):
			player.x = clampf(proposed.x, 65, 1085)
		proposed = player + Vector2(0, step.y)
		if cafe_map.can_stand(proposed):
			player.y = clampf(proposed.y, 210, 550)

func spawn_customer() -> void:
	if player.distance_to(flow.ENTRY)<48:
		return
	var free: Array = [0,1,2]
	for c in customers:
		free.erase(c["seat"])
		if Vector2(c.get("pos",SEATS[c["seat"]])).distance_to(flow.ENTRY)<48:
			return
	for seat in free.duplicate():
		if player.distance_to(SEATS[seat])<48:
			free.erase(seat)
	if free.is_empty():
		return
	var seat: int = free.pick_random()
	var species = randi_range(0,2)
	var order = randi_range(0,2)
	var customer = {"seat":seat,"species":species,"order":order,"left":PATIENCE[species],"total":PATIENCE[species]}
	flow.normalize(customer)
	customer["pos"] = flow.ENTRY
	customer["state"] = "entering"
	if randf()<0.4:
		var second = (order+randi_range(1,2))%3
		customer["items"].append(second)
		customer["pending"].append(second)
	var patience = patience_for(species,customer["items"])
	customer["left"] = patience
	customer["total"] = patience
	customers.append(customer)
	sync_customers()

func sync_customers(delta: float = 0.0) -> void:
	if not cafe_map:
		return
	cafe_map.customer_feet.clear()
	var active: Array = []
	for customer in customers:
		flow.normalize(customer)
		var seat: int = customer["seat"]
		active.append(seat)
		if not customer_nodes.has(seat):
			var actor = Node2D.new()
			actor.set_script(preload("res://customer_actor.gd"))
			actor.name = "Cliente"+str(seat)
			depth.add_child(actor)
			actor.setup(art["personagens/"+["gato","coelho","capivara"][customer["species"]]])
			customer_nodes[seat] = actor
		customer_nodes[seat].update_visual(customer,self,delta)
		cafe_map.customer_feet.append(customer["pos"]+Vector2(0,28))
	for seat in customer_nodes.keys():
		if not active.has(seat):
			customer_nodes[seat].queue_free()
			customer_nodes.erase(seat)

func can_interact(target: Vector2, radius: float) -> bool:
	if STATIONS.has(target):
		radius = minf(radius,PREP_REACH)
	return player.distance_to(target) < radius and cafe_map.clear_path(player+Vector2(0,28),target+Vector2(0,28))

func patience_for(species: int,items: Array) -> float:
	return PATIENCE[species]+24.0*maxi(0,items.size()-1)

func arrival_interval() -> float:
	return maxf(7.0,11.0-served*0.12)

func can_attend(seat: int) -> bool:
	return cafe_map.can_serve_table(seat,player)

func toast(value: String) -> void:
	message = value
	message_left = 4.0

func interact() -> void:
	if preparing>=0 or restock_left>0 or fox.serve_remaining>0:
		return
	for customer in customers:
		flow.normalize(customer)
		if customer["state"]=="waiting" and can_attend(customer["seat"]):
			deliver_to(customer)
			return
	for i in range(STATIONS.size()):
		if can_interact(STATIONS[i],100):
			if tray.size()>=TRAY_CAPACITY:
				toast("Bandeja cheia: 2/2. Entregue ou use Q para descartar um produto.")
				return
			if not can_prepare(i):
				sounds.play("error")
				toast("Sem ingredientes. Aperte R no balcao para repor.")
				return
			for k in range(4):
				stock[k] -= int(recipes[i]["cost"][k])
			preparing = i
			prep_left = float(recipes[i]["seconds"])
			sounds.play("prepare")
			toast("Preparando "+str(recipes[i]["name"])+"...")
			return
	toast("Aproxime-se de uma estacao ou cliente e aperte E.")

func deliver_to(customer: Dictionary) -> void:
	if tray.is_empty():
		toast("Prepare: "+pending_label(customer))
		return
	var matches: Array[int] = []
	var remaining_items: Array = customer["pending"].duplicate()
	for product_id in tray:
		if remaining_items.has(product_id):
			matches.append(product_id)
			remaining_items.erase(product_id)
	if matches.is_empty():
		sounds.play("error")
		toast("Os produtos da bandeja nao faltam neste pedido: "+pending_label(customer))
		return
	var first_texture: Texture2D = art["produtos_ui/"+["cafe","bolo","suco"][matches[0]]]
	var second_texture: Texture2D = art["produtos_ui/"+["cafe","bolo","suco"][matches[1]]] if matches.size()>1 else null
	fox.serve(first_texture,second_texture)
	for product_id in matches:
		customer["pending"].erase(product_id)
		customer["delivered"].append(product_id)
		tray.erase(product_id)
	if not customer["pending"].is_empty():
		sounds.play("partial")
		toast("Entrega parcial! Falta: "+pending_label(customer))
		return
	combo += 1
	var reward = mini(combo-1,5)*2
	for product_id in customer["items"]:
		reward += int(recipes[product_id]["price"])
	coins += reward
	served += 1
	sounds.play("deliver")
	customer["state"] = "consuming"
	customer["timer"] = 3.0
	customer["velocity"] = Vector2.ZERO
	toast("Pedido completo! +%d moedas. Combo %dx" % [reward,combo])

func pending_label(customer: Dictionary) -> String:
	var names = PackedStringArray()
	for item in customer["pending"]:
		names.append(str(recipes[item]["name"]))
	return " + ".join(names)

func can_prepare(id: int) -> bool:
	for i in range(4):
		if stock[i]<int(recipes[id]["cost"][i]):
			return false
	return true

func start_restock() -> void:
	if preparing>=0 or restock_left>0 or held>=0 or fox.serve_remaining>0:
		toast("Esvazie a bandeja antes de repor ingredientes.")
		return
	for point in STATIONS:
		if can_interact(point,100):
			restock_left = 3.0
			toast("Repondo ingredientes... aguarde 3 segundos.")
			return
	toast("Va para tras do balcao e aperte R para repor.")

func finish_round() -> void:
	if finished_round:
		return
	finished_round = true
	mode = "end"
	preparing = -1
	restock_left = 0
	sounds.register_score(coins)
	sounds.play("end")

func panel(rect: Rect2, color: Color, border: Color = INK) -> void:
	painter.draw_rect(Rect2(rect.position + Vector2(0, 5), rect.size), Color(0, 0, 0, 0.16))
	painter.draw_rect(rect, color)
	painter.draw_rect(rect, border, false, 3.0)

func label_at(value: String, pos: Vector2, size: int = 20, color: Color = INK) -> void:
	painter.draw_string(font, pos, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func centered(value: String, y: float, size: int = 24, color: Color = CREAM) -> void:
	var width = font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	label_at(value, Vector2((1152 - width) / 2, y), size, color)

func product(pos: Vector2, id: int, scale_value: float = 1.0) -> void:
	var key = "produtos_ui/" + ["cafe", "bolo", "suco"][id]
	if art.has(key):
		sprite_fit(key, Rect2(pos - Vector2(24, 28) * scale_value, Vector2(48, 48) * scale_value))
		return
	var s = scale_value
	if id == 0:
		draw_arc(pos + Vector2(15, 0) * s, 9 * s, -PI / 2, PI / 2, 16, CREAM, 4 * s)
		draw_rect(Rect2(pos + Vector2(-14, -12) * s, Vector2(28, 25) * s), CREAM)
		draw_ellipse_placeholder(pos + Vector2(0, -11) * s, Vector2(13, 5) * s, Color("6a3d29"))
		draw_line(pos + Vector2(-3, -20) * s, pos + Vector2(2, -29) * s, CREAM, 2 * s)
	elif id == 1:
		draw_colored_polygon(PackedVector2Array([pos + Vector2(-18, 13) * s, pos + Vector2(18, 13) * s, pos + Vector2(18, -8) * s, pos + Vector2(-18, -8) * s]), Color("713c32"))
		draw_rect(Rect2(pos + Vector2(-18, -2) * s, Vector2(36, 5) * s), Color("efb495"))
		draw_rect(Rect2(pos + Vector2(-18, -12) * s, Vector2(36, 5) * s), Color("ffe0b1"))
		draw_circle(pos + Vector2(7, -18) * s, 7 * s, Color("d45a65"))
	else:
		draw_rect(Rect2(pos + Vector2(-12, -16) * s, Vector2(24, 33) * s), Color("f18b95"))
		draw_rect(Rect2(pos + Vector2(-12, -16) * s, Vector2(24, 6) * s), CREAM)
		draw_line(pos + Vector2(3, -15) * s, pos + Vector2(9, -32) * s, GREEN, 4 * s)

func draw_ellipse_placeholder(pos: Vector2, radii: Vector2, color: Color) -> void:
	var points = PackedVector2Array()
	for i in range(24):
		var angle = TAU * i / 24
		points.append(pos + Vector2(cos(angle), sin(angle)) * radii)
	draw_colored_polygon(points, color)

func animal(pos: Vector2, kind: int, barista: bool = false) -> void:
	var key = "personagens/" + ["gato", "coelho", "capivara", "raposa"][kind]
	if art.has(key):
		sprite_fit(key, Rect2(pos + Vector2(-43, -59), Vector2(86, 94)))
		return
	var fur = [Color("dca369"), Color("f4e5ce"), Color("ab7954"), Color("df793e")][kind]
	draw_ellipse_placeholder(pos + Vector2(0, 26), Vector2(29, 9), Color(0, 0, 0, 0.16))
	draw_rect(Rect2(pos + Vector2(-18, 4), Vector2(36, 27)), GREEN if barista else Color("c57d75"))
	if kind == 1:
		draw_ellipse_placeholder(pos + Vector2(-13, -39), Vector2(8, 23), fur)
		draw_ellipse_placeholder(pos + Vector2(13, -39), Vector2(8, 23), fur)
		draw_line(pos + Vector2(-13, -51), pos + Vector2(-13, -30), Color("d59e9f"), 5)
	elif kind == 0 or kind == 3:
		draw_colored_polygon(PackedVector2Array([pos + Vector2(-25, -9), pos + Vector2(-23, -40), pos + Vector2(-4, -23)]), fur)
		draw_colored_polygon(PackedVector2Array([pos + Vector2(25, -9), pos + Vector2(23, -40), pos + Vector2(4, -23)]), fur)
	else:
		draw_circle(pos + Vector2(-19, -24), 8, fur)
		draw_circle(pos + Vector2(19, -24), 8, fur)
	draw_ellipse_placeholder(pos + Vector2(0, -9), Vector2(28, 25), fur)
	draw_ellipse_placeholder(pos + Vector2(0, 3), Vector2(16, 10), CREAM)
	draw_circle(pos + Vector2(-10, -12), 3, INK)
	draw_circle(pos + Vector2(10, -12), 3, INK)
	draw_circle(pos + Vector2(0, -2), 3, INK)
	if barista:
		draw_rect(Rect2(pos + Vector2(-10, 8), Vector2(20, 19)), CREAM)

func sprite_fit(key: String, box: Rect2) -> void:
	if not art.has(key):
		return
	var tex: Texture2D = art[key]
	var factor = minf(box.size.x / tex.get_width(), box.size.y / tex.get_height())
	var size = tex.get_size() * factor
	painter.draw_texture_rect(tex, Rect2(box.position + (box.size - size) / 2, size), false)

func environment_art() -> void:
	draw_rect(Rect2(0, 0, 1152, 648), INK)
	for y in range(168, 588, 140):
		for x in range(28, 1124, 274):
			draw_texture_rect(art["texturas/piso"], Rect2(x, y, 274, 140), false)
	draw_texture_rect(art["texturas/madeira_parede"], Rect2(28, 15, 1096, 172), false)
	# Janela, placa e prateleiras acompanham os grandes volumes da referência.
	panel(Rect2(30, 170, 47, 178), Color("fff0ba"))
	draw_line(Vector2(53, 171), Vector2(53, 347), Color("a67349"), 5)
	draw_line(Vector2(31, 255), Vector2(76, 255), Color("a67349"), 5)
	sprite_fit("objetos/placa", Rect2(33, 17, 260, 127))
	label_at("CAFÉ", Vector2(134, 66), 24, CREAM)
	label_at("COM PATAS", Vector2(126, 91), 14, CREAM)
	sprite_fit("objetos/lousa", Rect2(95, 165, 97, 110))
	sprite_fit("objetos/planta_pendente", Rect2(274, 15, 75, 135))
	for x in [365, 540]:
		sprite_fit("objetos/prateleira", Rect2(x, 26, 175, 64))
		for i in range(3):
			sprite_fit("objetos/pote_graos" if i % 2 == 0 else "objetos/pote", Rect2(x + 14 + i * 48, 16, 38, 53))
	sprite_fit("objetos/prateleira", Rect2(338, 105, 280, 75))
	for i in range(5):
		sprite_fit("objetos/pote" if i % 2 else "objetos/pote_graos", Rect2(350 + i * 48, 100, 35, 52))
	sprite_fit("objetos/cafeteira", Rect2(650, 120, 150, 102))
	sprite_fit("objetos/moedor", Rect2(796, 140, 49, 81))
	sprite_fit("objetos/prateleira", Rect2(981, 133, 113, 60))
	sprite_fit("objetos/flores", Rect2(1032, 113, 44, 60))
	sprite_fit("objetos/luminaria", Rect2(1058, 66, 61, 141))
	# O balcão e todos os objetos sobre o tampo são desenhados na mesma camada de profundidade.
	# Duas áreas de consumo, com centro livre.
	sprite_fit("objetos/tapete_vermelho", Rect2(61, 404, 253, 132))
	sprite_fit("objetos/tapete_verde", Rect2(879, 399, 221, 129))
	sprite_fit("objetos/quadro", Rect2(1067, 263, 46, 70))
	# Jardineira e abertura da entrada.
	panel(Rect2(450, 547, 248, 33), Color("9f704b"))
	for x in range(452, 689, 37):
		sprite_fit("objetos/planta_pequena", Rect2(x, 521, 45, 51))
	for x in [341, 790]:
		panel(Rect2(x, 535, 20, 48), Color("ab744d"))

func _draw() -> void:
	painter = self
	if not art.is_empty():
		environment_art()
	if hud:
		hud.queue_redraw()


