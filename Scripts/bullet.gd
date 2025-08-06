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
	rotation = direction_shot
	initial_position = global_position
	
	tracer.width = tracer_strength
	tracer.add_point(initial_position)
	
	var collider = get_collider()
	if collider:
		tracer.add_point(get_collision_point())
		if (collider.has_method("damage")):
			collider.damage(damage)
	#else: 
		#tracer.add_point(position+

	var fade_tween = get_tree().create_tween()
	fade_tween.tween_property(self, "modulate:a", 0, tracer_timeout)
	await fade_tween.finished
	fade_tween.kill()
	queue_free()
