extends SceneTree
func _initialize():
	call_deferred("verify")
func verify():
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	var sides = [
		[Vector2(554,340),Vector2(676,415),Vector2(554,492),Vector2(455,415)],
		[Vector2(184,362),Vector2(308,441),Vector2(184,522),Vector2(83,441)],
		[Vector2(976,364),Vector2(1078,452),Vector2(976,517),Vector2(878,439)]
	]
	for seat in range(3):
		for order in range(3):
			for point in sides[seat]:
				game.restart()
				game.customers = [{"seat":seat,"species":seat,"order":order,"left":40.0,"total":40.0}]
				game.sync_customers()
				game.player = point
				assert(game.cafe_map.can_stand(point),"Lado bloqueado: "+str(seat)+" "+str(point))
				assert(game.can_attend(seat),"Fora da area de atendimento")
				game.held = order
				game.interact()
				assert(game.served==1 and game.held==-1,"E nao entregou na mesa "+str(seat))
	for station in range(3):
		game.restart()
		game.customers.clear()
		game.sync_customers()
		game.player = game.STATIONS[station]
		assert(game.cafe_map.can_stand(game.player))
		for other in range(3):
			assert(game.can_interact(game.STATIONS[other],100)==(other==station),"Postos de preparo se confundem")
		game.interact()
		assert(game.preparing==station)
		game._process(2)
		assert(game.held==station)
	game.player = Vector2(530,220)
	assert(not game.can_attend(0) and not game.can_attend(1) and not game.can_attend(2))
	print("PASS: 36 entregas nos 4 lados das 3 mesas, cafe/cafeteira, bolo/vitrine e suco/geladeira sem ambiguidade")
	quit()
