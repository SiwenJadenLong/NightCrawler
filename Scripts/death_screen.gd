extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.player_death.connect(death)

func death():
	$Death_music.play(0)
	var death_tween = create_tween()
	death_tween.tween_property($Red, "scale:y", 1, 0.5).set_ease(Tween.EASE_IN)
	death_tween.tween_property($Restart, "modulate:a", 1, 1).set_ease(Tween.EASE_IN)
	await death_tween.finished
	death_tween.kill()

func _on_restart_pressed() -> void:
	$Death_music.stop()
	SignalBus.load_level.emit("house")
	$Red.scale.y = 0
	$Restart.modulate.a = 0
	hide()
