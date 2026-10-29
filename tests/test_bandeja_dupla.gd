extends SceneTree
func _initialize():
	call_deferred("verify")
func customer(game,seat: int,items: Array) -> Dictionary:
	var c = {"seat":seat,"species":seat,"order":items[0],"left":80.0,"total":80.0}
	game.flow.normalize(c)
	c["items"] = items.duplicate()
	c["pending"] = items.duplicate()
	return c
func verify():
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.restart()
	game.customers.clear()
	game.sync_customers()
	for id in [0,1]:
		game.player = game.STATIONS[id]
		game.interact()
		assert(game.preparing==id)
		game._process(2)
	assert(game.tray==[0,1])
	assert(game.fox.item.visible and game.fox.item_second.visible)
	var stock = game.stock.duplicate()
	game.player = game.STATIONS[2]
	game.interact()
	assert(game.preparing==-1 and game.stock==stock and game.tray==[0,1])
	game.customers = [customer(game,0,[0,1])]
	game.sync_customers()
	game.player = Vector2(554,340)
	game.interact()
	assert(game.tray.is_empty() and game.served==1 and game.coins==25)
	assert(game.fox.delivered_second!=null)
	game.restart()
	game.customers = [customer(game,0,[0])]
	game.sync_customers()
	game.tray.assign([0,0])
	game.player = Vector2(554,340)
	game.interact()
	assert(game.tray==[0] and game.served==1 and game.coins==10)
	game.restart()
	game.customers = [customer(game,0,[0]),customer(game,1,[1])]
	game.sync_customers()
	game.tray.assign([0,1])
	game.player = Vector2(554,340)
	game.interact()
	assert(game.tray==[1] and game.served==1)
	game._process(0.6)
	game.player = Vector2(184,362)
	game.interact()
	assert(game.tray.is_empty() and game.served==2)
	for species in range(3):
		assert(game.patience_for(species,[0,1])-game.patience_for(species,[0])==24)
	assert(game.patience_for(0,[0])==44 and game.patience_for(2,[0,1])==88)
	game.served = 0
	assert(game.arrival_interval()==11)
	game.served = 100
	assert(game.arrival_interval()==7)
	print("PASS v1.2: preparo duplo, dois sprites, capacidade 2, entrega conjunta/separada, item repetido preservado e tempos equilibrados")
	quit()
