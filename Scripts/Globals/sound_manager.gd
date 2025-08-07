extends Node
var BG_music_player

func playsound(sound : AudioStream, audio_Bus : String = "Master") -> void:
	var newsound = AudioStreamPlayer.new()
	newsound.bus = audio_Bus
	newsound.autoplay = true
	newsound.stream = sound
	newsound.pitch_scale = randf_range(1,1.2)
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

func play_2D_sound(sound: AudioStream, sound_origin : Vector2) -> void:
	pass
