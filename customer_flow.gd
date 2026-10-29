extends RefCounted
## Reservas e navegação em grade para o ciclo completo dos clientes.
const ENTRY = Vector2(386,540)
const ORIGIN = Vector2(64,210)
const SPACING = 8
var game: Node2D
var navigation: AStarGrid2D

func setup(owner_game: Node2D) -> void:
	game = owner_game
	navigation = AStarGrid2D.new()
	navigation.region = Rect2i(0,0,128,43)
	navigation.cell_size = Vector2.ONE*SPACING
	navigation.offset = ORIGIN
	navigation.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	navigation.update()

func normalize(c: Dictionary) -> void:
	if not c.has("state"):
		c["state"] = "waiting"
		c["pos"] = game.SEATS[c["seat"]]
		c["items"] = [c["order"]]
		c["pending"] = [c["order"]]
		c["delivered"] = []
		c["path"] = PackedVector2Array()
		c["wait"] = 0.0
		c["velocity"] = Vector2.ZERO
		c["timer"] = 0.0
		c["lost"] = false

func can_step(pos: Vector2, self_customer: Dictionary) -> bool:
	if not game.cafe_map.can_stand(pos,false):
		return false
	var own = Rect2(pos+Vector2(-11,21),Vector2(22,14))
	if own.intersects(Rect2(game.player+Vector2(-11,21),Vector2(22,14))):
		return false
	for c in game.customers:
		if c==self_customer:
			continue
		var other: Vector2 = c.get("pos",game.SEATS[c["seat"]])
		if own.intersects(Rect2(other+Vector2(-14,20),Vector2(28,16))):
			return false
	return true

func route(c: Dictionary,target: Vector2) -> PackedVector2Array:
	for y in range(43):
		for x in range(128):
			var id = Vector2i(x,y)
			var pos = ORIGIN+Vector2(id)*SPACING
			navigation.set_point_solid(id,not can_step(pos,c))
	var start = Vector2i(((c["pos"]-ORIGIN)/SPACING).round())
	var end = Vector2i(((target-ORIGIN)/SPACING).round())
	if not navigation.is_in_boundsv(start) or not navigation.is_in_boundsv(end):
		return PackedVector2Array()
	navigation.set_point_solid(start,false)
	if navigation.is_point_solid(end):
		return PackedVector2Array()
	var points = navigation.get_point_path(start,end)
	if not points.is_empty():
		points.append(target)
	return points

func move_route(c: Dictionary,delta: float,target: Vector2) -> bool:
	c["velocity"] = Vector2.ZERO
	c["wait"] = maxf(0,c["wait"]-delta)
	if c["path"].is_empty() and c["wait"]<=0:
		c["path"] = route(c,target)
		c["wait"] = 0.8
	var budget = delta * (84.0 if c["species"]==2 else 103.0)
	while budget>0 and not c["path"].is_empty():
		var next: Vector2 = c["path"][0]
		var current: Vector2 = c["pos"]
		if current.distance_to(next)<0.1:
			if can_step(next,c):
				c["pos"] = next
			c["path"].remove_at(0)
			continue
		var amount = minf(4.0,minf(budget,current.distance_to(next)))
		var direction = current.direction_to(next)
		var proposed = current+direction*amount
		if not can_step(proposed,c):
			c["path"] = PackedVector2Array()
			break
		c["pos"] = proposed
		c["velocity"] = direction
		budget -= amount
	return Vector2(c["pos"]).distance_to(target)<1

func update(delta: float) -> void:
	for i in range(game.customers.size()-1,-1,-1):
		var c: Dictionary = game.customers[i]
		normalize(c)
		match c["state"]:
			"entering":
				if move_route(c,delta,game.SEATS[c["seat"]]):
					c["state"] = "waiting"
					c["velocity"] = Vector2.ZERO
			"waiting":
				c["left"] -= delta
				if c["left"]<=0:
					game.missed += 1
					game.combo = 0
					game.reputation -= 1
					game.sounds.play("lost")
					c["lost"] = true
					c["state"] = "exiting"
					c["path"] = PackedVector2Array()
					game.toast("Cliente sem paciencia. Priorize as barras vermelhas!")
			"consuming":
				c["timer"] -= delta
				if c["timer"]<=0:
					c["state"] = "exiting"
					c["path"] = PackedVector2Array()
			"exiting":
				if move_route(c,delta,ENTRY):
					game.customers.remove_at(i)
