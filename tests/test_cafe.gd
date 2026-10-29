extends SceneTree

func _initialize() -> void:
	call_deferred("verify")

func verify() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.restart()
	assert(game.customers.size() == 1)
	var customer = game.customers[0]
	customer["state"] = "waiting"
	customer["pos"] = game.SEATS[customer["seat"]]
	customer["items"] = [customer["order"]]
	customer["pending"] = [customer["order"]]
	game.sync_customers()
	var order = customer["order"]
	game.player = game.STATIONS[order]
	game.interact()
	assert(game.preparing == order)
	game._process(2.0)
	assert(game.held == order)
	game.player = [Vector2(550,340),Vector2(325,425),Vector2(1072,380)][customer["seat"]]
	game.interact()
	assert(game.served == 1 and game.coins > 0 and game.held == -1)
	game.spawn_customer()
	for c in game.customers:
		if c["state"]=="entering":
			c["state"] = "waiting"
			c["pos"] = game.SEATS[c["seat"]]
	game.sync_customers()
	game._process(60.0)
	assert(game.missed >= 1)
	game.remaining = 0.01
	game._process(0.1)
	assert(game.mode == "end")
	game.restart()
	assert(game.served == 0 and game.reputation == 5)
	print("PASS: preparo, entrega, moedas, paciência, fim de partida e reinício")
	quit()
