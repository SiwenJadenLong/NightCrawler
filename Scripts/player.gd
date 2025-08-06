extends CharacterBody2D


@onready var Camera: Camera2D = $Camera2D
@onready var Body: Node2D = $Body
@export var body_rotate_speed : float = 0.25 * PI


const SPEED = 300.0

enum states{
	alive,
	dead,
	
}

var playerstate : states = states.alive

var rotation_difference : float = 0

func _physics_process(delta: float) -> void:
	match playerstate:
		states.alive:
			movement()
			move_and_slide()
			turn_to_cursor(delta)
			if Input.is_action_pressed("view ahead"):
				camera_view_ahead()
			else:
				Camera.global_position = global_position

func movement():
	var x_direction := Input.get_axis("left", "right")
	if x_direction:
		velocity.x = x_direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	var y_direction := Input.get_axis("up", "down")
	if y_direction:
		velocity.y = y_direction * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
func turn_to_cursor(delta):
	Body.rotation = get_angle_to(get_global_mouse_position())
	
func camera_view_ahead():
	Camera.global_position = (position+get_global_mouse_position())/2
