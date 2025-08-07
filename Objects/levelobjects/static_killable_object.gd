extends StaticBody2D

@export var hp : int = 1

func damage(damage_taken):
	if damage_taken >= hp:
		queue_free()
	else:
		hp =- damage_taken
