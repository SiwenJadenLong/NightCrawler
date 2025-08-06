extends Node2D
class_name weapon

@onready var bullet_spawn: Marker2D = $"Bullet Spawn"

const BULLET = preload("res://Objects/Effect Objects/bullet.tscn")
var can_shoot = true
@export var total_ammo : int
@export var magazine_capacity : int
@export var cyclic_rate : int
@export var tracer_timeout : float = 0.05
@export var weapon_damage : int = 40

func aim_exact_point_at_cursor():
	look_at(get_global_mouse_position())

func shoot():
	if can_shoot:
		var bullet = BULLET.instantiate()
		bullet.direction_shot = rotation
		bullet.tracer_timeout = tracer_timeout
		bullet.damage = weapon_damage
		bullet_spawn.add_child(bullet)
		can_shoot = false
		await get_tree().create_timer(cyclic_rate/6000)
		can_shoot = true

func _physics_process(delta: float) -> void:
	aim_exact_point_at_cursor()
		
	
