extends Node
var BG_music_player

func playsound(sound : AudioStream, audio_Bus : String = "Master", pitch_adjusted = true) -> void:
	var newsound = AudioStreamPlayer.new()
	newsound.bus = audio_Bus
	newsound.autoplay = true
	newsound.stream = sound
	if pitch_adjusted == true:
		newsound.pitch_scale = randf_range(1,1.2)
	elif pitch_adjusted is float:
		newsound.pitch_scale = pitch_adjusted
	add_child(newsound)
	await newsound.finished
	newsound.queue_free()

func _ready() -> void:
	BG_music_player = AudioStreamPlayer.new()
	add_child(BG_music_player)
	
func changeBGMusic(musicname : String) -> void:
	BG_music_player.stop()
	BG_music_player.stream = load("res://assets/music/%s.ogg" % musicname)
	BG_music_player.play()

func play_2D_sound(sound_origin : Vector2, sound: AudioStream, audio_Bus : String = "Master", pitch_adjustment = true) -> void:
	var newsound = AudioStreamPlayer2D.new()
	newsound.max_distance = 3000
	newsound.position = sound_origin
	newsound.bus = audio_Bus
	newsound.autoplay = true
	newsound.stream = sound
	newsound.panning_strength = 3
	if pitch_adjustment is float:
		newsound.pitch_scale = pitch_adjustment
	elif pitch_adjustment is bool:
		if pitch_adjustment:
			newsound.pitch_scale = randf_range(0.8,1.2)  
	add_child(newsound)
	await newsound.finished
	newsound.queue_free()
