extends Node2D
class_name weapon

@onready var bullet_spawn: Marker2D = $"Bullet Spawn"

const BULLET = preload("res://Objects/Effect Objects/bullet.tscn")
var can_shoot = true

@export var total_ammo : int
@export var magazine_capacity : int

@export var cyclic_rate : int
@export var tracer_timeout : float = 0.25
@export var weapon_damage : int = 40

@export var default_offset : Vector2 = Vector2(0,50)

@export var firing_sound : AudioStream

@onready var shooting_cooldown: Timer = $"Shooting Cooldown"

@onready var left_hand: RemoteTransform2D = $"Left Hand"
@onready var right_hand: RemoteTransform2D = $"Right Hand"

func aim_exact_point_at_cursor():
	look_at(get_global_mouse_position())

func shoot():
	if can_shoot:
		var bullet = BULLET.instantiate()
		sound_manager.playsound(firing_sound, "Sound_Effects")
		bullet.rotation = global_rotation
		bullet.tracer_timeout = tracer_timeout
		bullet.damage = weapon_damage
		bullet.initial_position = bullet_spawn.global_position
		SignalBus.newobject.emit(bullet_spawn.global_position, bullet)
		shooting_cooldown.start(1.0/(cyclic_rate/60.0))
		can_shoot = false

func _physics_process(delta: float) -> void:
	aim_exact_point_at_cursor()


func _on_shooting_cooldown_timeout() -> void:
	can_shoot = true
