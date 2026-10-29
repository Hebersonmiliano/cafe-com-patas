extends SceneTree
func _initialize():
	call_deferred("verify")
func verify():
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.restart()
	var fox = game.fox
	var dirs = {"baixo":Vector2.DOWN, "esquerda":Vector2.LEFT, "direita":Vector2.RIGHT, "cima":Vector2.UP}
	var tex = game.art["produtos_ui/cafe"]
	assert(fox.body.sprite_frames.get_animation_names().size() == 18)
	for d in dirs:
		fox.update_pose(0.01, dirs[d], false, false, null)
		assert(fox.current == "andar_" + d)
		fox.update_pose(0.15, dirs[d], false, false, null)
		assert(fox.body.frame > 0)
		fox.update_pose(0.01, Vector2.ZERO, false, false, null)
		assert(fox.current == "parada_" + d)
		fox.update_pose(0.01, dirs[d], true, false, tex)
		assert(fox.current == "carregar_" + d and fox.item.visible)
		fox.update_pose(0.01, Vector2.ZERO, true, false, tex)
		assert(fox.current == "segurar_" + d)
	fox.update_pose(0.01, Vector2.ZERO, false, true, tex)
	assert(fox.current == "preparar")
	fox.serve(tex)
	fox.update_pose(0.15, Vector2.ZERO, false, false, null)
	assert(fox.current == "entregar" and fox.body.frame == 1 and fox.item.visible)
	game.mode = "pause"
	var time = fox.clock
	game._process(2.0)
	assert(fox.clock == time)
	game.mode = "play"
	fox.update_pose(0.4, Vector2.ZERO, false, false, null)
	assert(fox.current == "parada_baixo" and not fox.item.visible)
	game.restart()
	assert(fox.serve_remaining == 0 and fox.body.frame == 0)
	for animation in fox.body.sprite_frames.get_animation_names():
		for i in range(fox.body.sprite_frames.get_frame_count(animation)):
			var im = fox.body.sprite_frames.get_frame_texture(animation, i).get_image()
			assert(im.get_size() == Vector2i(128,128))
			assert(im.get_pixel(0,0).a == 0)
	print("PASS: 18 animações, direções, transporte, preparo, entrega, pausa, reinício e transparência")
	quit()
