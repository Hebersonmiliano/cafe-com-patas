extends Node
## Efeitos e pequena melodia sintetizados em código, sem arquivos de terceiros.
const RATE = 22050
var effects: Dictionary = {}
var channels: Array[AudioStreamPlayer] = []
var music: AudioStreamPlayer
var effects_enabled = true
var music_enabled = false
var volume = 0.85
var bass_enabled = true
var music_versions: Dictionary = {}
var best_score = 0
var paused = false
var playback_enabled = DisplayServer.get_name()!="headless"
const PROFILE = "user://cafe_com_patas.cfg"

func synth(notes: Array,note_seconds: float,amplitude: float=0.18) -> AudioStreamWAV:
	var samples = int(notes.size()*note_seconds*RATE)
	var data = PackedByteArray()
	data.resize(samples*2)
	for i in range(samples):
		var time = i/float(RATE)
		var index = mini(int(time/note_seconds),notes.size()-1)
		var local = fmod(time,note_seconds)
		var frequency: float = notes[index]
		var envelope = sin(PI*minf(1,local/0.012)/2.0)*exp(-local*6)*minf(1,(note_seconds-local)/0.018)
		var wave = sin(TAU*frequency*time)+0.22*sin(TAU*frequency*2*time)+0.28*sin(TAU*frequency*0.5*time)
		var value = wave*envelope*amplitude if frequency>0 else 0.0
		data.encode_s16(i*2,int(clampf(value,-1,1)*32767))
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.data = data
	return stream

func _ready() -> void:
	var profile = ConfigFile.new()
	if profile.load(PROFILE)==OK:
		effects_enabled = profile.get_value("audio","effects",true)
		music_enabled = profile.get_value("audio","music",false)
		volume = clampf(float(profile.get_value("audio","volume",0.85)),0,1)
		bass_enabled = profile.get_value("audio","bass",true)
		best_score = maxi(0,int(profile.get_value("score","best",0)))
	var definitions = {
		"step":[[110,0],0.045],"prepare":[[196,262,330],0.08],"ready":[[523,659],0.1],
		"partial":[[440,554],0.08],"deliver":[[523,659,784,1047],0.08],"error":[[160,120],0.1],
		"lost":[[330,262,196],0.12],"open":[[392,523,659],0.11],"end":[[659,523,392],0.18],
		"restock":[[262,330,392],0.09]
	}
	for key in definitions:
		effects[key] = synth(definitions[key][0],definitions[key][1],0.065 if key=="step" else 0.32)
	for i in range(5):
		var channel = AudioStreamPlayer.new()
		if OS.has_feature("web"):
			channel.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
		add_child(channel)
		channels.append(channel)
	music = AudioStreamPlayer.new()
	if OS.has_feature("web"):
		music.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
	add_child(music)
	music_versions[false] = synth_music(false)
	music_versions[true] = synth_music(true)
	music.stream = music_versions[bass_enabled]
	apply_volume()

func synth_music(with_bass: bool) -> AudioStreamWAV:
	# Contrabaixo com harmônicos audíveis também em caixas pequenas.
	var melody = [262,330,392,330,294,349,440,349,262,330,392,523,440,392,330,0,262,330,392,330,294,349,440,349,392,330,294,262,294,330,262,0]
	var roots = [65.406,73.416,65.406,98.0,65.406,73.416,98.0,65.406]
	var seconds = 0.24
	var samples = int(melody.size()*seconds*RATE)
	var data = PackedByteArray()
	data.resize(samples*2)
	for i in range(samples):
		var time = i/float(RATE)
		var note = mini(int(time/seconds),melody.size()-1)
		var local = fmod(time,seconds)
		var frequency: float = melody[note]
		var envelope = minf(1,local/0.012)*exp(-local*4)*minf(1,(seconds-local)/0.025)
		var value = (sin(TAU*frequency*local)+0.12*sin(TAU*frequency*2*local))*envelope*0.22 if frequency>0 else 0.0
		if with_bass:
			var bass_time = fmod(time,seconds*4)
			var root_note: float = roots[mini(int(time/(seconds*4)),roots.size()-1)]
			var bass_envelope = minf(1,bass_time/0.025)*exp(-bass_time*1.7)*minf(1,(seconds*4-bass_time)/0.045)
			value += (sin(TAU*root_note*bass_time)+0.48*sin(TAU*root_note*2*bass_time)+0.20*sin(TAU*root_note*3*bass_time))*bass_envelope*0.24
			# Pulso suave, sem encobrir os sons de pedidos e entregas.
			var beat = fmod(time,seconds*2)
			value += sin(TAU*(48*beat+24*0.025*(1-exp(-beat/0.025))))*exp(-beat*23)*minf(1,beat/0.004)*0.09
		# Limitador suave preserva margem antes da conversão para PCM.
		data.encode_s16(i*2,int(tanh(value*1.25)*0.85*32767))
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.data = data
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = samples
	return stream

func play(cue: String) -> void:
	if not playback_enabled or not effects_enabled or paused or not effects.has(cue):
		return
	for channel in channels:
		if not channel.playing:
			channel.stream = effects[cue]
			channel.play()
			return

func apply_volume() -> void:
	var db = linear_to_db(maxf(0.0001,volume))
	for channel in channels:
		channel.volume_db = db
	if music:
		music.volume_db = db-3

func update_state(mode: String) -> void:
	paused = mode=="pause"
	for channel in channels:
		channel.stream_paused = paused
	if music:
		if playback_enabled and music_enabled and mode=="play" and not music.playing:
			music.play()
		music.stream_paused = paused or mode!="play"

func save_profile() -> void:
	var profile = ConfigFile.new()
	profile.set_value("audio","effects",effects_enabled)
	profile.set_value("audio","music",music_enabled)
	profile.set_value("audio","volume",volume)
	profile.set_value("audio","bass",bass_enabled)
	profile.set_value("score","best",best_score)
	profile.save(PROFILE)

func settings_key(key: int) -> bool:
	match key:
		KEY_F:
			effects_enabled = not effects_enabled
			if not effects_enabled:
				for channel in channels:
					channel.stop()
		KEY_M:
			music_enabled = not music_enabled
			if not music_enabled:
				music.stop()
		KEY_B:
			bass_enabled = not bass_enabled
			var position_seconds = music.get_playback_position() if playback_enabled and music.playing else 0.0
			var was_playing = music.playing
			music.stream = music_versions[bass_enabled]
			if playback_enabled and was_playing:
				music.play(position_seconds)
			music.stream_paused = paused
		KEY_MINUS,KEY_KP_SUBTRACT:
			volume = maxf(0,volume-0.1)
		KEY_EQUAL,KEY_PLUS,KEY_KP_ADD:
			volume = minf(1,volume+0.1)
		_:
			return false
	apply_volume()
	save_profile()
	return true

func register_score(score: int) -> void:
	best_score = maxi(best_score,score)
	save_profile()

func shutdown() -> void:
	for channel in channels:
		channel.stop()
		channel.stream = null
	if music:
		music.stop()
		music.stream = null
	effects.clear()
	music_versions.clear()

func _exit_tree() -> void:
	shutdown()

