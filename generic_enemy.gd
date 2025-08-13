extends CharacterBody2D

@onready var enemy_body: Node2D = $Body
@onready var enemy_head: Node2D = $Head

@onready var left_hand: Sprite2D = $"Hands/Left Hand"
@onready var right_hand: Sprite2D = $"Hands/Right Hand"

@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var held_item: Node2D = $"held item"

@onready var shooting_cooldown: Timer = $"shooting cooldown"

@export var BULLET : PackedScene
@export var bullet_casing : PackedScene
@export var muzzle_flash_textures : Array[Texture2D]
@export var firing_sound : AudioStream
@onready var muzzle_flash_lighting: PointLight2D = $"held item/pistol/muzzle flash lighting"
@onready var muzzle_flash: PointLight2D = $"held item/pistol/muzzle flash"
@onready var pistol: Node2D = $"held item/pistol"
@export var hit_sound : AudioStream


const SPEED : int = 250
var enemy_state : enemy_states
var hp : int = 100

var last_known_player_position : Vector2

enum enemy_states {
	patroling,
	attacking,
	searching,
	covering,
	stationary
}

#func follow_next_line():
func _ready() -> void:
	set_hands_to_item()


func _physics_process(delta: float) -> void:
	match enemy_state:
		enemy_states.patroling:
			pass
		enemy_states.attacking:
			turn_towards_thing(last_known_player_position)
			ray_cast_2d.look_at(last_known_player_position)
			if ray_cast_2d.get_collider() is player:
				last_known_player_position = ray_cast_2d.get_collider().global_position
			shoot()
		enemy_states.searching:
			pass
		enemy_states.covering:
			pass
		enemy_states.stationary:
			pass

func set_hands_to_item():
	left_hand.position = held_item.get_child(0).get_node("Left Hand").position
	right_hand.position = held_item.get_child(0).get_node("Right Hand").position

func turn_towards_thing(thing):
	if thing is not Vector2:
		look_at(thing.global_position)
		look_at(thing.global_position)
		held_item.get_child(0).look_at(thing.global_positon)
	else:
		look_at(thing)
		look_at(thing)
		held_item.get_child(0).look_at(thing)
func _on_player_detection_body_entered(body: Node2D) -> void:
	if body is player:
		await get_tree().create_timer(0.5).timeout
		ray_cast_2d.look_at(body.global_position)
		
#		Await Physics Frame for Raycast Detection
		await get_tree().physics_frame
		await get_tree().physics_frame
		await get_tree().physics_frame
		await get_tree().physics_frame
		
		var casted = ray_cast_2d.get_collider()
		if casted is player:
			last_known_player_position = body.global_position
			enemy_state = enemy_states.attacking

func shoot():
	if shooting_cooldown.time_left == 0:
		shooting_cooldown.start(0.6)
		play_firing_sounds()
		show_muzzle_flash()
		var bullet = BULLET.instantiate()
		bullet.tracer_timeout = 0.2
		bullet.damage = 30
		bullet.initial_position = held_item.global_position
		SignalBus.newobject.emit(pistol.global_position, bullet, global_rotation)
		SignalBus.newobject.emit(pistol.global_position, bullet_casing.instantiate(), global_rotation)

func play_firing_sounds():
	sound_manager.play_2D_sound(held_item.global_position, firing_sound,"Sound Effects", randf_range(0.98,1.02))
#
func show_muzzle_flash():
	muzzle_flash_lighting.energy = randf_range(1, 3)
	muzzle_flash_lighting.scale = Vector2(randf_range(0.8,1.4),randf_range(0.8,1.4))
	
	muzzle_flash.texture = muzzle_flash_textures[randi_range(0,muzzle_flash_textures.size()-1)]
	muzzle_flash.energy = randf_range(1.5, 2)
	muzzle_flash.scale = Vector2(randf_range(0.5,1),randf_range(0.5,1))
	
	muzzle_flash_lighting.show()
	muzzle_flash.show()
	await get_tree().physics_frame
	muzzle_flash_lighting.hide()
	muzzle_flash.hide()

func damage(damage_taken):
	if damage_taken >= hp:
		SignalBus.emit_signal("winconditioncheck")
		queue_free()
	else:
		hp -= damage_taken
	sound_manager.play_2D_sound(global_position, hit_sound, "Sound Effects", false)


func _on_shooting_cooldown_timeout() -> void:
	shooting_cooldown.stop()
