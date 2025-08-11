extends Node2D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);

func _on_play_button_pressed() -> void:
	SignalBus.load_level.emit("test_level")


func _on_quit_pressed() -> void:
	get_tree().quit()
