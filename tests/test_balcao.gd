extends SceneTree
func _initialize():
	call_deferred("verify")
func verify():
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.restart()
	game.customers.clear()
	game.sync_customers()
	assert(game.cafe_map.can_stand(game.player))
	for x in [280,350,450,650,805,900]:
		game.player = Vector2(x,220)
		assert(game.cafe_map.can_stand(game.player))
		game.move_player(Vector2(0,200))
		assert(game.cafe_map.can_stand(game.player))
		var sole_y = game.player.y-20+(122-64)*0.86
		assert(sole_y<261,"A pata entrou no tampo em x="+str(x))
	game.player = Vector2(530,220)
	game.move_player(Vector2(470,0))
	assert(game.player.distance_to(Vector2(1000,220))<1,"Passagem diante da geladeira bloqueada")
	game.move_player(Vector2(0,140))
	assert(game.player.distance_to(Vector2(1000,360))<1,"Saida direita bloqueada")
	game.move_player(Vector2(0,-140))
	game.move_player(Vector2(-470,0))
	assert(game.player.distance_to(Vector2(530,220))<1)
	var front = game.depth.get_node("FrenteBalcao")
	assert(front.has_node("caixa") and front.has_node("redoma") and front.has_node("vitrine"))
	assert(front.position.y>game.player.y+28)
	for entry in game.cafe_map.furniture:
		if entry["name"]=="geladeira":
			assert(entry["node"].position.y<game.player.y+28)
	for station in game.STATIONS:
		game.player = station
		assert(game.cafe_map.can_stand(game.player) and game.can_interact(station,100))
	print("PASS v1.1.1: patas fora do tampo, objetos em primeiro plano, passagem e retorno diante da geladeira, preparo acessivel")
	quit()
