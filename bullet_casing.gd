extends Sprite2D
var random_rotation : float
var random_positon : Vector2

func _ready() -> void:
	random_rotation = randf_range(PI, 5*PI)
	random_positon = Vector2(randi_range(-5,-70),randi_range(30,100))+position
	var tween = create_tween()
	tween.tween_property(self,"position",random_positon,randf_range(0.2,0.5)).set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"rotation",random_rotation,randf_range(0.2,0.5)).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(GlobalVariables.effect_decay_timer).timeout
	queue_free()
