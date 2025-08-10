extends StaticBody2D

@export var hp : int = 1
@export var hit_sound : AudioStream
@export var killable : bool

func damage(damage_taken):
	if killable:
		if damage_taken >= hp:
			queue_free()
		else:
			hp =- damage_taken
	sound_manager.play_2D_sound(global_position, hit_sound, "Sound Effects", false)
