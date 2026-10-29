extends Node
## Efeitos e pequena melodia sintetizados em código, sem arquivos de terceiros.
const RATE = 22050
var effects: Dictionary = {}
var channels: Array[AudioStreamPlayer] = []
var music: AudioStreamPlayer
var effects_enabled = true
var music_enabled = false
var volume = 0.65
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
		var wave = sin(TAU*frequency*time)+0.22*sin(TAU*frequency*2*time)
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
		volume = clampf(float(profile.get_value("audio","volume",0.65)),0,1)
		best_score = maxi(0,int(profile.get_value("score","best",0)))
	var definitions = {
		"step":[[110,0],0.045],"prepare":[[196,262,330],0.08],"ready":[[523,659],0.1],
		"partial":[[440,554],0.08],"deliver":[[523,659,784,1047],0.08],"error":[[160,120],0.1],
		"lost":[[330,262,196],0.12],"open":[[392,523,659],0.11],"end":[[659,523,392],0.18],
		"restock":[[262,330,392],0.09]
	}
	for key in definitions:
		effects[key] = synth(definitions[key][0],definitions[key][1],0.05 if key=="step" else 0.18)
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
	var tune = synth([262,330,392,330,294,349,440,349,262,330,392,523,440,392,330,0,262,330,392,330,294,349,440,349,392,330,294,262,294,330,262,0],0.24,0.08)
	tune.loop_mode = AudioStreamWAV.LOOP_FORWARD
	tune.loop_begin = 0
	tune.loop_end = tune.data.size()/2
	music.stream = tune
	apply_volume()

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
		music.volume_db = db-5

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

func _exit_tree() -> void:
	shutdown()
