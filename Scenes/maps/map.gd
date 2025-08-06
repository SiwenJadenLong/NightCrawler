extends Node2D

@onready var objects: Node = $Objects

func _ready() -> void:
	SignalBus.newobject.connect(spawn_object)
	
func spawn_object(object_position : Vector2, object : Node):
	object.global_position = object_position
	objects.add_child(object)
