extends SceneTree
func rms(data: PackedByteArray,low_pass: bool=false) -> float:
	var total = 0.0
	var filtered = 0.0
	var alpha = 1-exp(-TAU*180/22050.0)
	for i in range(data.size()/2):
		var value = data.decode_s16(i*2)/32768.0
		filtered += alpha*(value-filtered)
		total += pow(filtered if low_pass else value,2)
	return sqrt(total/(data.size()/2))
func _initialize():
	call_deferred("verify")
func verify():
	var sound = load("res://cafe_audio.gd").new()
	root.add_child(sound)
	var bass: AudioStreamWAV = sound.music_versions[true]
	var normal: AudioStreamWAV = sound.music_versions[false]
	var old = sound.synth([262,330,392,330,294,349,440,349,262,330,392,523,440,392,330,0,262,330,392,330,294,349,440,349,392,330,294,262,294,330,262,0],0.24,0.08)
	assert(rms(bass.data)>rms(old.data)*2.5)
	assert(rms(bass.data,true)>rms(normal.data,true)*1.5)
	var peak = 0
	for i in range(bass.data.size()/2):
		peak = maxi(peak,absi(bass.data.decode_s16(i*2)))
	assert(peak<30000)
	assert(absi(bass.data.decode_s16(0))<2)
	assert(absi(bass.data.decode_s16(bass.data.size()-2))<100)
	assert(bass.loop_end==normal.loop_end)
	var original = sound.bass_enabled
	sound.settings_key(KEY_B)
	assert(sound.bass_enabled!=original and sound.music.stream==sound.music_versions[not original])
	var profile = ConfigFile.new()
	assert(profile.load(sound.PROFILE)==OK and profile.get_value("audio","bass")==not original)
	sound.settings_key(KEY_B)
	assert(sound.bass_enabled==original)
	sound.volume = 0
	sound.apply_volume()
	assert(sound.music.volume_db<-70)
	print("PASS audio v1.3: RMS antigo=",rms(old.data)," novo=",rms(bass.data),"; graves ON/OFF=",rms(bass.data,true),"/",rms(normal.data,true),"; pico PCM=",peak,"; loop, silencio e preferencia B verificados")
	sound.shutdown()
	quit()

