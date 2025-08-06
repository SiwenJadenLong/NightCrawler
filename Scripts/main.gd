extends Node


# Called when the node enters the scene tree for the first time.
@onready var level_container: Node2D = $"Level Container"


var level_instance;

func unloadLevel():
	if (is_instance_valid(level_instance)):
		level_instance.queue_free();
	level_instance = null;

func loadNewScene(level_number):
	unloadLevel();
	var level_path : String
#	If
	if level_number is int:
		level_path = 
	else:
		level_path = 
	
	var level_resource : PackedScene = load(level_path);
	if level_resource:
		level_instance = level_resource.instantiate();
		level_container.add_child(level_instance);
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
