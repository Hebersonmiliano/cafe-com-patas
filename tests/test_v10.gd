extends SceneTree
func _initialize():
	call_deferred("verify")
func verify():
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	assert(game.sounds.effects.size()>=10)
	for key in game.sounds.effects:
		var stream: AudioStreamWAV = game.sounds.effects[key]
		assert(stream.mix_rate==22050 and stream.data.size()>100)
	var original_volume = game.sounds.volume
	var original_music = game.sounds.music_enabled
	var original_effects = game.sounds.effects_enabled
	game.sounds.settings_key(KEY_F)
	assert(game.sounds.effects_enabled!=original_effects)
	game.sounds.settings_key(KEY_F)
	game.sounds.settings_key(KEY_M)
	assert(game.sounds.music_enabled!=original_music)
	game.sounds.settings_key(KEY_M)
	for i in range(15):
		game.sounds.settings_key(KEY_MINUS)
	assert(game.sounds.volume==0)
	for i in range(15):
		game.sounds.settings_key(KEY_PLUS)
	assert(game.sounds.volume==1)
	game.sounds.volume = original_volume
	game.sounds.save_profile()
	seed(2026)
	game.restart()
	for tick in range(1900):
		if game.mode!="play":
			break
		if game.preparing<0 and game.restock_left<=0 and game.fox.serve_remaining<=0:
			var waiting: Dictionary = {}
			for c in game.customers:
				if c["state"]=="waiting" and (game.held<0 or c["pending"].has(game.held)):
					waiting = c
					break
			if not waiting.is_empty():
				if game.held>=0:
					game.player = [Vector2(550,340),Vector2(325,425),Vector2(1072,380)][waiting["seat"]]
					game.interact()
				else:
					var product_id: int = waiting["pending"][0]
					game.player = game.STATIONS[product_id]
					if not game.can_prepare(product_id):
						game.start_restock()
					else:
						game.interact()
			elif game.held>=0:
				game.held = -1
			else:
				game.player = Vector2(530,220)
		game._process(0.1)
	assert(game.mode=="end" and game.finished_round)
	assert(game.served>=8,"Meta nao atingida na simulacao: "+str(game.served))
	assert(game.sounds.best_score>=game.coins)
	var result = game.coins
	game.finish_round()
	assert(game.coins==result)
	game.restart()
	assert(not game.finished_round and game.remaining==180 and game.coins==0)
	print("PASS v1.0: audio sintetizado, controles/volume, partida completa de 180s, meta, resultado, recorde e reinicio. Recorde em moedas: ",game.sounds.best_score)
	game.sounds.shutdown()
	await create_timer(0.15).timeout
	quit()
