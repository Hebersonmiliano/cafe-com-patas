extends SceneTree
func _initialize():
	call_deferred("verify")

func customer_for(game,seat: int,species: int) -> Dictionary:
	var c = {"seat":seat,"species":species,"order":0,"left":58.0,"total":58.0}
	game.flow.normalize(c)
	c["pos"] = game.flow.ENTRY
	c["state"] = "entering"
	c["items"] = [0,1]
	c["pending"] = [0,1]
	return c

func verify():
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	for seat in range(3):
		for species in range(3):
			game.restart()
			game.customers = [customer_for(game,seat,species)]
			game.sync_customers()
			var c: Dictionary = game.customers[0]
			for tick in range(600):
				game.flow.update(0.05)
				assert(game.cafe_map.can_stand(c["pos"],false))
				if c["state"]=="waiting":
					break
			assert(c["state"]=="waiting","Entrada sem rota: "+str(seat))
			var service = [Vector2(550,340),Vector2(325,425),Vector2(1072,380)][seat]
			game.player = service
			game.held = 0
			game.interact()
			assert(c["pending"]==[1] and game.served==0 and game.coins==0)
			game.fox.update_pose(1,Vector2.ZERO,false,false,null)
			game.held = 0
			game.interact()
			assert(game.held==0 and c["pending"]==[1] and game.coins==0)
			game.held = 1
			game.interact()
			assert(c["state"]=="consuming" and game.served==1 and game.coins==25)
			game.player = Vector2(530,220)
			for tick in range(1000):
				game.flow.update(0.05)
				if game.customers.is_empty():
					break
			if not game.customers.is_empty():
				print("DEBUG EXIT ",seat," ",c["pos"]," state=",c["state"]," path=",c["path"]," wait=",c["wait"]," valid=",game.cafe_map.can_stand(c["pos"],false))
			assert(game.customers.is_empty(),"Saida sem rota: "+str(seat))
	game.restart()
	game.customers.clear()
	game.sync_customers()
	game.player = game.STATIONS[0]
	game.interact()
	assert(game.stock==[11,11,16,10])
	game._process(2)
	assert(game.held==0)
	game.held = -1
	game.stock = [0,0,0,0]
	game.interact()
	assert(game.preparing==-1)
	game.start_restock()
	assert(game.restock_left==3)
	game._process(3.1)
	assert(game.stock==game.INITIAL_STOCK and game.restock_left==0)
	var c = customer_for(game,0,0)
	c["state"] = "waiting"
	c["pos"] = game.SEATS[0]
	c["left"] = 0.01
	game.customers = [c]
	game.flow.update(0.1)
	assert(game.missed==1 and game.reputation==4 and c["state"]=="exiting")
	game.flow.update(0.1)
	assert(game.missed==1)
	# Entrada simultânea, reservas exclusivas e pausa do ciclo.
	game.restart()
	for tick in range(650):
		game._process(0.05)
	assert(game.customers.size()==3)
	var seats: Array = []
	for client in game.customers:
		assert(client["state"]=="waiting","Cliente nao chegou ao assento: "+str(client["seat"]))
		assert(not seats.has(client["seat"]))
		seats.append(client["seat"])
	for i in range(game.customers.size()):
		for j in range(i+1,game.customers.size()):
			var a = game.customers[i]["pos"]
			var b = game.customers[j]["pos"]
			assert(not Rect2(a+Vector2(-11,21),Vector2(22,14)).intersects(Rect2(b+Vector2(-11,21),Vector2(22,14))))
	var positions = []
	for client in game.customers:
		positions.append(client["pos"])
	game.mode = "pause"
	game._process(5)
	for i in range(game.customers.size()):
		assert(positions[i]==game.customers[i]["pos"])
	print("PASS v0.9: 9 ciclos entrada/espera/consumo/saida, entrega parcial, duplicata rejeitada, estoque, reposicao, paciencia e pausa")
	quit()
