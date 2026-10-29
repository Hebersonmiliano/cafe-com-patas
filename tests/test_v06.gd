extends SceneTree
const ORIGIN = Vector2(64,210)
const SPACING = 8
func _initialize():
	call_deferred("verify")

func grid_for(game) -> AStarGrid2D:
	var grid = AStarGrid2D.new()
	grid.region = Rect2i(0,0,128,43)
	grid.cell_size = Vector2.ONE * SPACING
	grid.offset = ORIGIN
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	grid.update()
	for y in range(43):
		for x in range(128):
			var pos = ORIGIN + Vector2(x,y)*SPACING
			grid.set_point_solid(Vector2i(x,y), not game.cafe_map.can_stand(pos))
	return grid

func go(game,grid: AStarGrid2D,target: Vector2) -> void:
	var start = Vector2i(((game.player-ORIGIN)/SPACING).round())
	var end = Vector2i(((target-ORIGIN)/SPACING).round())
	var route = grid.get_point_path(start,end)
	assert(not route.is_empty(),"Destino inacessível: " + str(target))
	for point in route:
		game.move_player(point-game.player)
		assert(game.cafe_map.can_stand(game.player))
	assert(game.player.distance_to(target)<12)

func verify():
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.restart()
	game.customers.clear()
	game.sync_customers()
	assert(game.cafe_map.solids.size() >= 20)
	assert(game.depth.y_sort_enabled)
	assert(game.fox is CharacterBody2D)
	for rect in game.cafe_map.solids:
		assert(not game.cafe_map.can_stand(rect.get_center()-Vector2(0,28),false))
	var grid = grid_for(game)
	for order in range(3):
		for seat in range(3):
			game.restart()
			game.customers = [{"seat":seat,"species":seat,"order":order,"left":58.0,"total":58.0}]
			game.sync_customers()
			grid = grid_for(game)
			go(game,grid,game.STATIONS[order])
			game.interact()
			assert(game.preparing == order)
			game._process(2.0)
			assert(game.held == order)
			var candidates = [Vector2(550,340),Vector2(325,425),Vector2(1072,380)]
			go(game,grid,candidates[seat])
			assert(game.can_attend(seat),"Atendimento bloqueado: " + str(seat))
			game.interact()
			assert(game.served==1 and game.coins>0)
	game.restart()
	game.customers.clear()
	game.sync_customers()
	assert(not game.cafe_map.clear_path(Vector2(530,250),Vector2(530,370)))
	assert(not game.cafe_map.clear_path(Vector2(170,430),Vector2(170,510)))
	assert(game.cafe_map.clear_path(Vector2(330,420),Vector2(250,461)))
	game.player = game.SEATS[0]
	for i in range(8):
		game.spawn_customer()
		for c in game.customers:
			c["state"] = "waiting"
			c["pos"] = game.SEATS[c["seat"]]
		game.sync_customers()
	assert(game.customers.size()==2)
	for c in game.customers:
		assert(c["seat"] != 0)
	print("PASS v0.6: móveis/parede bloqueiam, 9 rotas com colisões e entregas, interação sem atravessar obstáculos, Y-sort, reserva sem sobrepor jogador")
	quit()
