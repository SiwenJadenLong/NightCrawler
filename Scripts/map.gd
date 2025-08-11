extends Node2D

@onready var spawn_objects: Node2D = $"Spawn Objects"

func _ready() -> void:
	SignalBus.newobject.connect(spawn_object)
	
func spawn_object(object_position : Vector2, object : Node, object_rotation : float = 0):
	object.global_position = object_position
	object.rotation = object_rotation
	spawn_objects.add_child(object)
