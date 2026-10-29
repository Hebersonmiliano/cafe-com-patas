extends SceneTree
func _initialize():
	call_deferred("verify")
func verify():
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.restart()
	assert(game.hud.z_index>0)
	for hearts in range(6):
		game.reputation = hearts
		var model = game.hud.view_model()
		assert(model.hearts==hearts and model.hearts+model.empty_hearts==5)
	game.coins = 1234
	game.combo = 7
	game.served = 22
	game.held = 2
	game.remaining = 59
	var model = game.hud.view_model()
	assert(model.coins==1234 and model.combo==7 and model.held==2 and model.served==22 and model.time=="00:59")
	game.mode = "pause"
	game._process(30)
	assert(game.hud.view_model().time=="00:59")
	for seat in range(3):
		var origin = game.hud.bubble_origin(seat)
		assert(origin.x>=0 and origin.x+118<=1152 and origin.y>=0 and origin.y+78<548)
	game.restart()
	assert(game.hud.view_model().time=="03:00" and game.hud.view_model().coins==0 and game.hud.view_model().hearts==5)
	print("PASS v0.7: corações, números, moedas acima de 999, pausa, pedidos dentro da tela e reinício")
	quit()
