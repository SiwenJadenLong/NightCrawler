extends Node


# Called when the node enters the scene tree for the first time.
@onready var death_screen: Control = $"Popups/Popups Control/Death Screen"
@onready var level_container: Node2D = $"Level Container"
@onready var damage_vignette: TextureRect = $"screen effects/Vignette/Damage Vignette"
@onready var popups_control: Control = $"Popups/Popups Control"

@export var debugvariable : bool = false
@export var loading_message : PackedScene
var level_instance;


func _ready() -> void:
	load_new_map("main_menu")
	SignalBus.load_level.connect(load_new_map)
	SignalBus.player_death.connect(death)
	SignalBus.win.connect(win)
	SignalBus.update_player_hp_effects.connect(update_player_effects)
	GlobalVariables.debug = debugvariable
	
#	Load loading message, fade out, then queue_free
	var new_loading_message = loading_message.instantiate()
	popups_control.add_child(new_loading_message)
	await get_tree().create_timer(3).timeout
	var loading_fade_tween = create_tween().tween_property(new_loading_message,"modulate:a", 0, 2)
	await loading_fade_tween.finished
	new_loading_message.queue_free()
	

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
	
#	Reset Player Stats:
	GlobalVariables.player_hp = 100

func death():
	unload_level()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	death_screen.show()
	

func win():
	unload_level()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$"Popups/Popups Control/Win".show()

func update_player_effects():
	if GlobalVariables.player_hp == 60:
		AudioServer.add_bus_effect(1, AudioEffectReverb.new())
		damage_vignette.modulate.a = 0.5
	
	elif GlobalVariables.player_hp == 20:
		var new_amplify = AudioEffectAmplify.new()
		new_amplify.volume_db = -30
		AudioServer.add_bus_effect(1, new_amplify)
		AudioServer.add_bus_effect(1, AudioEffectDistortion.new())
		damage_vignette.modulate.a = 1
	
	elif GlobalVariables.player_hp == 0:
		SignalBus.player_death.emit()
		for i in AudioServer.get_bus_effect_count(1):
			AudioServer.remove_bus_effect(1, 0)
		damage_vignette.modulate.a = 0
		
