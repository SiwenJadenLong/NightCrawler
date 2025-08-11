extends Node2D

@onready var spawn_objects: Node2D = $"Spawn Objects"

func _ready() -> void:
	SignalBus.newobject.connect(spawn_object)
	SignalBus.winconditioncheck.connect(win_condition)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
func spawn_object(object_position : Vector2, object : Node, object_rotation : float = 0):
	object.global_position = object_position
	object.rotation = object_rotation
	spawn_objects.add_child(object)

func win_condition():
	if $enemies.get_child_count() == 1:
		SignalBus.win.emit()
