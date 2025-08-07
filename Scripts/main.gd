extends Node


# Called when the node enters the scene tree for the first time.
@onready var level_container: Node2D = $"Level Container"


var level_instance;

func unload_level() -> void:
	if (is_instance_valid(level_instance)):
		level_instance.queue_free();
	level_instance = null;

func load_new_map(map_name) -> void:
	unload_level();
	var level_path : String
#	If
	if map_name is int:
		level_path = "res://Scenes/maps/%s.tscn" % str(map_name)
	else:
		level_path = "res://Scenes/maps/%s.tscn" % map_name
	
	var level_resource : PackedScene = load(level_path);
	if level_resource:
		level_instance = level_resource.instantiate();
		level_container.add_child(level_instance);

func _ready() -> void:
	load_new_map("test_level")
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN);
