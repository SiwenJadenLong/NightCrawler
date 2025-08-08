extends StaticBody2D

@export var hp : int = 1
@export var hit_sound : AudioStream

func damage(damage_taken):
	if damage_taken >= hp:
		sound_manager.play_2D_sound(global_position, hit_sound, "Master", false)
		queue_free()
	else:
		hp =- damage_taken
