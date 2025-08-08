extends Node2D
class_name weapon



const BULLET = preload("res://Objects/Effect Objects/bullet.tscn")

var can_shoot = true
var chambered = true

var reload_transition = false
var new_mag = false
var inserting_new_mag = false

@export_category("Stats")
@export var weapon_damage : int = 40
@export var cyclic_rate : int
@export var starting_mags : int
@export var mag_capacity : int


@export_category("Positioning")
@export var default_left_hand_offset : Vector2 = Vector2(0,50)

@export_category("Visuals")
@export var tracer_timeout : float = 0.25
@export var muzzle_flash_textures : Array[Texture2D]

@export_subgroup("Sounds")
@export var firing_sound : AudioStream
@export var bullet_case_drop_sound : AudioStream
@export var bullet_case_delay_variance : float = 0.2

@export var mag_eject : AudioStream
@export var mag_insert : AudioStream
@export var hammer_drop : AudioStream
@export var dead_trigger : AudioStream
@export var bolt_forward : AudioStream
@export var bold_backward : AudioStream


@onready var bullet_spawn: Marker2D = $"Bullet Spawn"
@onready var shooting_cooldown: Timer = $"Shooting Cooldown"
@onready var left_hand: RemoteTransform2D = $"Left Hand"
@onready var right_hand: RemoteTransform2D = $"Right Hand"
@onready var muzzle_flash_lighting: PointLight2D = $"Muzzle Device/muzzle flash lighting"
@onready var muzzle_flash: PointLight2D = $"Muzzle Device/muzzle flash"

enum states{
	chambered_mag,
	unchambered_mag,
	chambered_no_mag,
	unchambered_no_mag,
	bolt_back_mag,
	bolt_back_no_mag
}

var weaponstate : states = states.chambered_mag
var magazines : Array[int]
var current_roundcount : int

#Debug variables:
@onready var debug: Node2D = $debug
@onready var state_label: Label = $"debug/State Label"



func _ready() -> void:
#	debug code
	debug.visible = GlobalVariables.debug

#	Gives gun starting amount of magazines
	for i in range(starting_mags):
		magazines.append(mag_capacity)
#	Pops first magazine into gun
	current_roundcount = magazines.pop_front()

#currently placeholder, will stop using once recoil is created
func aim_exact_point_at_cursor():
	look_at(get_global_mouse_position())

func shoot():
	if chambered:
		play_firing_sounds()
		show_muzzle_flash()
		var bullet = BULLET.instantiate()
		bullet.rotation = global_rotation
		bullet.tracer_timeout = tracer_timeout
		bullet.damage = weapon_damage
		bullet.initial_position = bullet_spawn.global_position
		SignalBus.newobject.emit(bullet_spawn.global_position, bullet)
		chambered = false
		shooting_cooldown.start(1.0/(cyclic_rate/60.0))



func _physics_process(_delta: float) -> void:
	aim_exact_point_at_cursor()
	
	if GlobalVariables.debug:
		debug.global_rotation = 0
		match weaponstate:
			states.chambered_mag:
				state_label.text = "chambered_mag"
			states.unchambered_mag:
				state_label.text = "unchambered_mag"
			states.chambered_no_mag:
				state_label.text = "chambered_no_mag"
			states.unchambered_no_mag:
				state_label.text = "unchambered_no_mag"
			states.bolt_back_mag:
				state_label.text = "bolt_back_mag"
			states.bolt_back_no_mag:
				state_label.text = "bolt_back_no_mag"
	
	match weaponstate:
		states.chambered_mag:
			#reload_transition = false
			if Input.is_action_pressed("Shoot"):
				shoot()
			if current_roundcount == 0:
				weaponstate = states.bolt_back_mag
			if Input.is_action_just_pressed("Reload"):
#				TODO make topping off reloads possible :\
				pass
		states.unchambered_mag:
			pass
		states.chambered_no_mag:
			pass
		states.unchambered_no_mag:
			pass
		states.bolt_back_mag:
			if Input.is_action_just_pressed("Shoot"):
				if current_roundcount == 0:
					sound_manager.play_2D_sound(global_position, hammer_drop,"Sound Effects", false)
					
			if Input.is_action_just_pressed("Reload"):
				reload_transition = true
				eject_and_retain_mag()
			if reload_transition:
				if inserting_new_mag:
					inserting_new_mag = false
					
				elif new_mag:
					if current_roundcount != 0:
						release_bolt()
				else:
					eject_and_retain_mag()
		
		states.bolt_back_no_mag:
			print("bolt back no mag")
				

func release_bolt():
	sound_manager.play_2D_sound(global_position, bolt_forward,"Sound Effects", false)
	chambered = true
	weaponstate = states.chambered_mag
	new_mag = false
	reload_transition = false

#TODO Make reload timing adjustible via variable
func insert_new_mag():
	sound_manager.play_2D_sound(global_position, mag_insert,"Sound Effects", true)
	await get_tree().create_timer(1).timeout
	current_roundcount = magazines.pop_front()
	weaponstate = states.bolt_back_mag
	new_mag = true

func eject_and_retain_mag():
	sound_manager.play_2D_sound(global_position, mag_eject,"Sound Effects", true)
	magazines.append(current_roundcount)
	weaponstate = states.bolt_back_no_mag
	current_roundcount = 0
	inserting_new_mag = true
	await get_tree().create_timer(1).timeout
	if reload_transition:
		insert_new_mag()



func pickupround():
	if current_roundcount != 0:
		chambered = true
		current_roundcount -= 1

func play_firing_sounds():
	sound_manager.play_2D_sound(muzzle_flash.global_position, firing_sound,"Sound Effects", false)
	await get_tree().create_timer(randf_range(1-bullet_case_delay_variance,1+bullet_case_delay_variance)).timeout
	sound_manager.playsound(bullet_case_drop_sound, "Sound Effects")
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
	


func _on_shooting_cooldown_timeout() -> void:
	pickupround()
	shooting_cooldown.stop()
