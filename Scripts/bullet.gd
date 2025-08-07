extends RayCast2D
class_name hitscan_bullet

var direction_shot : float
@export var tracer_strength : float = 3.0
var initial_position : Vector2
var damage : float
@onready var tracer: Line2D = $Tracer
@export var tracer_timeout : float 
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
#	Me when Godot says nuh uh you have to wait 2 frames for raycasts to work
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	
	tracer.width = tracer_strength
	var collider = get_collider()
	print(get_collider())
	print(get_collision_point())
	if collider:
		var variable = (global_position - get_collision_point()).length()
		tracer.add_point(Vector2(variable,0))
		if (collider.has_method("damage")):
			collider.damage(damage)
	else: 
		tracer.add_point(Vector2.RIGHT * 5000)
	
	var fade_tween = get_tree().create_tween()
	fade_tween.tween_property(self, "modulate:a", 0, tracer_timeout)
	await fade_tween.finished
	fade_tween.kill()
	queue_free()
