extends Node2D
class_name weapon



const BULLET = preload("res://Objects/Effect Objects/bullet.tscn")
var can_shoot = true


@export_category("Stats")
@export var weapon_damage : int = 40
@export var cyclic_rate : int
@export var total_ammo : int
@export var magazine_capacity : int


@export_category("Positioning")
@export var default_left_hand_offset : Vector2 = Vector2(0,50)

@export_category("Visuals")
@export var tracer_timeout : float = 0.25

@export_subgroup("Sounds")
@export var firing_sound : AudioStream
@export var bullet_case_drop_sound : AudioStream
@export var bullet_case_delay : float = 0.2

@onready var bullet_spawn: Marker2D = $"Bullet Spawn"
@onready var shooting_cooldown: Timer = $"Shooting Cooldown"
@onready var left_hand: RemoteTransform2D = $"Left Hand"
@onready var right_hand: RemoteTransform2D = $"Right Hand"

func aim_exact_point_at_cursor():
	look_at(get_global_mouse_position())

func shoot():
	if can_shoot:
		play_firing_sounds()
		var bullet = BULLET.instantiate()
		bullet.rotation = global_rotation
		bullet.tracer_timeout = tracer_timeout
		bullet.damage = weapon_damage
		bullet.initial_position = bullet_spawn.global_position
		SignalBus.newobject.emit(bullet_spawn.global_position, bullet)
		shooting_cooldown.start(1.0/(cyclic_rate/60.0))
		can_shoot = false

func _physics_process(delta: float) -> void:
	aim_exact_point_at_cursor()

func play_firing_sounds():
	sound_manager.playsound(firing_sound, "Sound_Effects")
	await get_tree().create_timer(randf_range(1-bullet_case_delay,1+bullet_case_delay)).timeout
	sound_manager.playsound(bullet_case_drop_sound, "Sound_Effects")


func _on_shooting_cooldown_timeout() -> void:
	can_shoot = true
