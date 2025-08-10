extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(GlobalVariables.effect_decay_timer).timeout
	queue_free()
