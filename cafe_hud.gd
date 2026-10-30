extends Node2D
const Pixel = preload("res://pixel_font.gd")
const CREAM = Color("fff0d2")
const INK = Color("493127")
const GOLD = Color("f9cf77")
var game: Node2D

func text(value: String,pos: Vector2,size: int=2,color: Color=CREAM) -> void:
	Pixel.draw(self,value,pos,size,color)

func center(value: String,pos: Vector2,size: int=2,color: Color=CREAM) -> void:
	text(value,pos-Vector2((value.length()*6-1)*size/2.0,0),size,color)

func wood(box: Rect2) -> void:
	draw_rect(Rect2(box.position+Vector2(0,4),box.size),Color(0,0,0,0.25))
	draw_rect(box,INK)
	draw_rect(box.grow(-3),Color("be8759"))
	draw_rect(box.grow(-6),Color("70462f"))
	draw_rect(Rect2(box.position+Vector2(7,7),Vector2(box.size.x-14,2)),Color("d4a371"))

func icon(key: String,box: Rect2) -> void:
	var texture: Texture2D = game.art.get("produtos_ui/"+key)
	if not texture:
		return
	var factor = minf(box.size.x/texture.get_width(),box.size.y/texture.get_height())
	var size = texture.get_size()*factor
	draw_texture_rect(texture,Rect2(box.position+(box.size-size)/2,size),false)

func view_model() -> Dictionary:
	return {"coins":game.coins,"hearts":game.reputation,"empty_hearts":5-game.reputation,"day":1,"time":"%02d:%02d" % [int(game.remaining)/60,int(game.remaining)%60],"combo":game.combo,"held":game.held,"served":game.served,"stock":game.stock.duplicate(),"tray":game.tray.duplicate()}

func bubble_origin(seat: int) -> Vector2:
	var pos: Vector2 = game.SEATS[seat]
	return pos+Vector2(35,-72) if seat==0 else pos+Vector2(-62,-116)

func draw_orders() -> void:
	for customer in game.customers:
		if customer.get("state","waiting")!="waiting":
			continue
		var b = bubble_origin(customer["seat"])
		var box = Rect2(b,Vector2(118,56))
		draw_rect(box,INK)
		draw_rect(box.grow(-3),CREAM)
		draw_colored_polygon(PackedVector2Array([b+Vector2(45,54),b+Vector2(56,64),b+Vector2(60,54)]),INK)
		draw_colored_polygon(PackedVector2Array([b+Vector2(49,52),b+Vector2(55,59),b+Vector2(57,52)]),CREAM)
		var items: Array = customer.get("items",[customer["order"]])
		for i in range(items.size()):
			var origin = b+Vector2(6+i*54,4)
			icon(["cafe","bolo","suco"][items[i]],Rect2(origin,Vector2(48,36)))
			text(["CAFE","BOLO","SUCO"][items[i]],origin+Vector2(9,39),1,INK)
			if customer.get("delivered",[]).has(items[i]):
				draw_line(origin+Vector2(13,21),origin+Vector2(23,30),Color("39834c"),4)
				draw_line(origin+Vector2(23,30),origin+Vector2(39,10),Color("39834c"),4)
		if items.size()==1:
			text(game.SPECIES[customer["species"]],b+Vector2(58,23),1,INK)
		var ratio: float = clampf(customer["left"]/customer["total"],0,1)
		draw_rect(Rect2(b+Vector2(6,66),Vector2(106,10)),INK)
		draw_rect(Rect2(b+Vector2(8,68),Vector2(102,6)),CREAM)
		var color = Color("72b954") if ratio>0.55 else Color("e7b64e") if ratio>0.25 else Color("d55850")
		draw_rect(Rect2(b+Vector2(8,68),Vector2(102*ratio,6)),color)
		if ratio<=0.25:
			text("!",b+Vector2(114,67),1,Color("d55850"))

func _draw() -> void:
	if not game:
		return
	var state = view_model()
	wood(Rect2(763,19,132,60))
	icon("moeda",Rect2(773,29,37,37))
	text("%03d" % state.coins,Vector2(817,36),3 if state.coins<1000 else 2)
	wood(Rect2(900,19,153,60))
	for i in range(5):
		draw_rect(Rect2(909+i*27,32,24,31),Color("bc8c61"))
		icon("coracao" if i<state.hearts else "coracao_vazio",Rect2(910+i*27,35,23,24))
	wood(Rect2(1060,14,68,76))
	draw_rect(Rect2(1066,20,56,15),Color("c55953"))
	draw_rect(Rect2(1066,35,56,48),CREAM)
	for x in [1073,1108]:
		draw_rect(Rect2(x,10,4,15),INK)
	center("DIA",Vector2(1094,41),2,INK)
	center("1",Vector2(1094,62),2,INK)
	wood(Rect2(951,87,101,32))
	center(state.time,Vector2(1001,96),2,GOLD)
	# Rótulos associados aos equipamentos, não a posições arbitrárias do balcão.
	for entry in [["CAFE",Vector2(725,107)],["BOLO",Vector2(838,195)],["SUCO",Vector2(973,125)]]:
		var width = entry[0].length()*12+16
		draw_rect(Rect2(entry[1]-Vector2(width/2.0,4),Vector2(width,22)),INK)
		center(entry[0],entry[1],2,GOLD)
	draw_orders()
	if game.preparing>=0 or game.restock_left>0:
		var p: Vector2 = game.player+Vector2(-34,-66)
		wood(Rect2(p,Vector2(68,12)))
		var progress = 1.0-game.restock_left/3.0 if game.restock_left>0 else clampf(1.0-game.prep_left/float(game.recipes[game.preparing]["seconds"]),0,1)
		draw_rect(Rect2(p+Vector2(4,4),Vector2(60*progress,4)),GOLD)
	# Estoque consumido no preparo e reposto manualmente com R.
	wood(Rect2(402,548,473,84))
	for i in range(4):
		var slot = Rect2(414+i*78,558,67,64)
		draw_rect(slot,INK)
		draw_rect(slot.grow(-2),CREAM)
		icon(["graos","leite","morango","bolo"][i],Rect2(slot.position+Vector2(6,3),Vector2(41,38)))
		draw_rect(Rect2(slot.position+Vector2(38,28),Vector2(27,18)),CREAM)
		text("%02d" % state.stock[i],slot.position+Vector2(39,30),2,INK if state.stock[i]>0 else Color("b54842"))
		center(["GRAOS","LEITE","FRUTA","BOLO"][i],Vector2(slot.get_center().x,607),2,INK)
	center("COMBO",Vector2(810,564),2,GOLD)
	center("%dX" % state.combo,Vector2(810,589),3,GOLD)
	wood(Rect2(33,548,220,63))
	text("BANDEJA %d/2" % state.tray.size(),Vector2(46,556),2)
	for i in range(2):
		var slot = Rect2(45+i*99,576,94,27)
		draw_rect(slot,CREAM)
		if i<state.tray.size():
			var product_id: int = state.tray[i]
			icon(["cafe","bolo","suco"][product_id],Rect2(slot.position+Vector2(2,1),Vector2(27,25)))
			text(["CAFE","BOLO","SUCO"][product_id],slot.position+Vector2(34,7),2,INK)
		else:
			text("-",slot.position+Vector2(40,7),2,INK)
	wood(Rect2(899,550,222,58))
	text("ATENDIDOS",Vector2(913,561),2)
	text("%02d/%02d" % [state.served,game.SERVICE_GOAL],Vector2(1020,582),2,GOLD)
	text("WASD MOVER E INTERAGIR R REPOR Q DESCARTAR ESC PAUSA",Vector2(37,630),2)
	text("V"+game.RELEASE,Vector2(1091,630),1,GOLD)
	text("F SOM M MUSICA",Vector2(903,630),2)
	# Dica curta somente ao estar perto de um ponto alcançável.
	if game.mode=="play" and game.preparing<0 and game.restock_left<=0 and game.fox.serve_remaining<=0:
		var hint = ""
		for c in game.customers:
			if c.get("state","waiting")=="waiting" and game.can_attend(c["seat"]):
				hint = "E ENTREGAR" if state.held>=0 else "E VER PEDIDO"
				break
		if hint=="":
			for i in range(3):
				if game.can_interact(game.STATIONS[i],100):
					hint = "E PREPARAR "+["CAFE","BOLO","SUCO"][i]
					break
		if hint!="":
			var origin = game.player+Vector2(0,-86)
			var width = hint.length()*12+14
			origin.x = clampf(origin.x,width/2.0+8,1152-width/2.0-8)
			draw_rect(Rect2(origin-Vector2(width/2.0,4),Vector2(width,23)),INK)
			center(hint,origin,2,CREAM)
	if game.message_left>0 and game.mode=="play":
		draw_rect(Rect2(203,505,746,29),INK)
		var message: String = game.message
		if message.length()>94:
			message = message.left(91)+"..."
		var short_message = message.left(59)+"..." if message.length()>62 else message
		center(short_message,Vector2(576,512),2,CREAM)
	if game.mode!="play":
		draw_rect(Rect2(0,0,1152,648),Color(0.12,0.07,0.05,0.9))
		wood(Rect2(152,125,848,396))
		if game.mode=="title":
			center("CAFE COM PATAS",Vector2(576,156),4,GOLD)
			center("UMA PEQUENA CAFETERIA. GRANDES AMIZADES.",Vector2(576,210),2)
			center("1 LEIA O PEDIDO DO CLIENTE",Vector2(576,271),2)
			center("2 PREPARE NO BALCAO COM E",Vector2(576,311),2)
			center("3 LEVE AO CLIENTE E APERTE E",Vector2(576,351),2)
			center("R REPOE INGREDIENTES NO BALCAO",Vector2(576,390),2)
			center("BANDEJA PARA 2 PRODUTOS",Vector2(576,453),1)
			center("ENTER PARA JOGAR",Vector2(576,427),3,GOLD)
			center("META 8 CLIENTES / 3 MIN / 5 CORACOES",Vector2(576,478),2)
			center("EMILLY LIMA / ANA JULIA RODRIGUES / PROF. HEBERSON MILIANO",Vector2(576,553),1)
			center("MUNDO SENAI",Vector2(576,580),2,GOLD)
		elif game.mode=="pause":
			center("PAUSA PARA UM CAFE",Vector2(576,245),3,GOLD)
			center("ESC PARA CONTINUAR",Vector2(576,335),2)
			center("F SOM "+("ON" if game.sounds.effects_enabled else "OFF")+" / M MUSICA "+("ON" if game.sounds.music_enabled else "OFF"),Vector2(576,385),2)
			center("+/- VOLUME %d/100" % int(game.sounds.volume*100),Vector2(576,425),2)
			center("B GRAVES "+("ON" if game.sounds.bass_enabled else "OFF"),Vector2(576,451),2)
			center("RECORDE %d MOEDAS" % game.sounds.best_score,Vector2(576,474),2,GOLD)
		else:
			var title = "DIA DE SUCESSO!" if state.served>=game.SERVICE_GOAL and state.hearts>0 else "EXPEDIENTE ENCERRADO"
			center(title,Vector2(576,196),3,GOLD)
			center("MOEDAS %d / ATENDIDOS %d" % [state.coins,state.served],Vector2(576,280),2)
			center("CLIENTES QUE SAIRAM %d" % game.missed,Vector2(576,325),2)
			center("RECORDE LOCAL %d MOEDAS" % game.sounds.best_score,Vector2(576,367),2,GOLD)
			center("ENTER PARA JOGAR NOVAMENTE",Vector2(576,426),2,GOLD)

