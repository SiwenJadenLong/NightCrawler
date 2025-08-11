extends Node


# Called when the node enters the scene tree for the first time.
@onready var level_container: Node2D = $"Level Container"
@export var debugvariable : bool = false

var level_instance;


func _ready() -> void:
	load_new_map("main_menu")
	SignalBus.load_level.connect(load_new_map)
	GlobalVariables.debug = debugvariable

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
