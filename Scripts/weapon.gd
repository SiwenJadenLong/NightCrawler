extends Node2D
class_name weapon


@export var BULLET : PackedScene

var chambered = true
var swapping_mag = false
var mag_in_hand : int
var weapon_locked : bool = false
var barrel_clipping : bool = false

var double_tap_delay := 0.25
var double_tap_time : float
var reload_taps : int = 0
var last_action

@export_category("Stats")
@export var weapon_damage : int = 40
@export var cyclic_rate : int
@export var starting_mags : int
@export var mag_capacity : int


@export_subgroup("Recoil")
@export var recoil_base : float
@export var max_recoil : float

@export_subgroup("Reloading")
@export var full_reload_penalty : float
@export var mag_swap_time : float

@export_category("Positioning")
@export var default_left_hand_offset : Vector2 = Vector2(0,50)

@export_category("Cosmetics")
@export var tracer_timeout : float = 0.25
@export var muzzle_flash_textures : Array[Texture2D]
@export var dropped_mag : PackedScene
@export var bullet_casing : PackedScene

@export_subgroup("Sounds")
@export var firing_sound : AudioStream
@export var bullet_case_drop_sound : AudioStream
@export var bullet_case_delay_variance : float = 0.2


@export var mag_eject : AudioStream
@export var actual_mag_eject_time : float
@export var mag_insert : AudioStream
@export var actual_mag_insert_time : float
@export var mag_drop : AudioStream
@export var hammer_drop : AudioStream
@export var dead_trigger : AudioStream
@export var bolt_forward : AudioStream
@export var actual_bolt_forward_time : float
@export var bolt_backward : AudioStream
@export var actual_bolt_backward_time : float


@onready var bullet_spawn: Marker2D = $"Bullet Spawn"
@onready var shooting_cooldown: Timer = $"Shooting Cooldown"
@onready var left_hand: RemoteTransform2D = $"Left Hand"
@onready var right_hand: RemoteTransform2D = $"Right Hand"
@onready var muzzle_flash_lighting: PointLight2D = $"Muzzle Device/muzzle flash lighting"
@onready var muzzle_flash: PointLight2D = $"Muzzle Device/muzzle flash"
@onready var clipping_check: Area2D = $"clipping check"

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
	SignalBus.pass_max_capacity.emit(current_roundcount)
	SignalBus.update_magazines.emit(current_roundcount,magazines, true)
#currently placeholder, will stop using once recoil is created
func aim_exact_point_at_cursor():
	look_at(get_global_mouse_position())

func shoot():
	if chambered:
		play_firing_sounds()
		show_muzzle_flash()
		var bullet = BULLET.instantiate()
		bullet.tracer_timeout = tracer_timeout
		bullet.damage = weapon_damage
		bullet.initial_position = bullet_spawn.global_position
		SignalBus.newobject.emit(bullet_spawn.global_position, bullet, global_rotation)
		chambered = false
		current_roundcount -= 1
		shooting_cooldown.start(1.0/(cyclic_rate/60.0))
		SignalBus.newobject.emit($"bullet casing spawn".global_position, bullet_casing.instantiate(), global_rotation)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_R:
			if last_action == event.as_text_keycode():
				double_tap_time = 0
			last_action = event.as_text_keycode()

func _physics_process(_delta: float) -> void:
	double_tap_time += _delta
	
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

	if !weapon_locked:
		match weaponstate:
				states.chambered_mag:
					if Input.is_action_pressed("Shoot") and current_roundcount != 0:
						shoot()
					elif current_roundcount == 0:
						weaponstate = states.bolt_back_mag
					if ( shooting_cooldown.time_left == 0 and !swapping_mag):
						if(Input.is_action_just_pressed("Reload")):
							if double_tap_time < 0.25:
								swapping_mag = true
								last_action = null
								eject_and_discard_mag()
							await get_tree().create_timer(0.25).timeout
							if !swapping_mag:
								swapping_mag = true
								last_action = null
								eject_and_retain_mag()

				states.unchambered_mag:
					if Input.is_action_just_pressed("Shoot"):
						if current_roundcount == 0:
							sound_manager.play_2D_sound(global_position, hammer_drop,"Sound Effects", false)
						
				states.chambered_no_mag:
					if Input.is_action_just_pressed("Shoot") and !barrel_clipping:
						shoot()
						swapping_mag = false
						weapon_locked = true
						weaponstate = states.unchambered_no_mag
					
				states.unchambered_no_mag:
					if Input.is_action_just_pressed("Shoot"):
						sound_manager.play_2D_sound(global_position, hammer_drop,"Sound Effects", false)
					if (Input.is_action_just_pressed("Reload") 
					and shooting_cooldown.time_left == 0):
							weapon_locked = true
							insert_new_mag()
						
				states.bolt_back_mag:
					if Input.is_action_just_pressed("Shoot"):
						sound_manager.play_2D_sound(global_position, hammer_drop,"Sound Effects", false)
					if (!swapping_mag):
						if(Input.is_action_just_pressed("Reload")):
							if double_tap_time < 0.25:
								weapon_locked = true
								swapping_mag = true
								last_action = null
								eject_and_discard_mag()
							await get_tree().create_timer(0.25).timeout
							if !swapping_mag:
								weapon_locked = true
								swapping_mag = true
								last_action = null
								eject_and_retain_mag()
					
				states.bolt_back_no_mag:
					if Input.is_action_just_pressed("Shoot"):
						sound_manager.play_2D_sound(global_position, hammer_drop,"Sound Effects", false)
				
func pull_bolt():
	weaponstate = states.bolt_back_mag
	sound_manager.play_2D_sound(global_position, bolt_backward,"Sound Effects", false)
	await get_tree().create_timer(bolt_backward.get_length()).timeout
	release_bolt()

func release_bolt():
	sound_manager.play_2D_sound(global_position, bolt_forward,"Sound Effects", false)
	await get_tree().create_timer(actual_bolt_forward_time).timeout
	pickupround()
	weaponstate = states.chambered_mag
	swapping_mag = false
	weapon_locked = false

func insert_new_mag():
	sound_manager.play_2D_sound(global_position, mag_insert,"Sound Effects", true)
	SignalBus.show_magazines.emit()
	if magazines:
		mag_in_hand = magazines.pop_front()
		await get_tree().create_timer(actual_mag_insert_time).timeout
		current_roundcount = mag_in_hand
		match weaponstate:
			states.bolt_back_no_mag:
				weaponstate = states.bolt_back_mag
				if current_roundcount != 0:
					release_bolt()
			states.chambered_no_mag:
				weaponstate = states.chambered_mag
			states.unchambered_no_mag:
				weaponstate = states.unchambered_mag
				if current_roundcount != 0:
					pull_bolt()
				else:
					weapon_locked = false
		SignalBus.update_magazines.emit(current_roundcount,magazines, true)
		swapping_mag = false

func eject_and_retain_mag():
	sound_manager.play_2D_sound(global_position, mag_eject,"Sound Effects", true)
	magazines.append(current_roundcount)
	match weaponstate:
		states.bolt_back_mag:
			weaponstate = states.bolt_back_no_mag
		states.chambered_mag:
			weaponstate = states.chambered_no_mag
	SignalBus.show_magazines.emit()
	current_roundcount = 0
	SignalBus.update_magazines.emit(current_roundcount,magazines, false)
	await get_tree().create_timer(mag_swap_time).timeout
	weapon_locked = false
	if swapping_mag:
		insert_new_mag()

func eject_and_discard_mag():
	drop_mag()
	match weaponstate:
		states.bolt_back_mag:
			weaponstate = states.bolt_back_no_mag
		states.chambered_mag:
			weaponstate = states.chambered_no_mag
	SignalBus.show_magazines.emit()
	current_roundcount = 0
	SignalBus.update_magazines.emit(current_roundcount,magazines, false)
	#await get_tree().create_timer(0.25).timeout
	weapon_locked = false
	if swapping_mag:
		insert_new_mag()
		


func drop_mag():
	sound_manager.play_2D_sound(global_position, mag_eject,"Sound Effects", true)
	var new_dropped_mag = dropped_mag.instantiate()
	SignalBus.newobject.emit(global_position, new_dropped_mag, randf_range(0, 2*PI))
	await get_tree().create_timer(0.25)
	sound_manager.play_2D_sound(global_position, mag_drop,"Sound Effects", true)

func pickupround():
	if current_roundcount != 0:
		chambered = true
	else:
		chambered = true
	SignalBus.updateroundcount.emit(current_roundcount)

func play_firing_sounds():
	sound_manager.play_2D_sound(muzzle_flash.global_position, firing_sound,"Sound Effects", randf_range(0.98,1.02))
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


#func _on_clipping_check_body_entered(body: Node2D) -> void:
	#print(clipping_check.get_overlapping_bodies())
	##for clippedbody in clipping_check.get_overlapping_bodies():
		##if clippedbody is not player:
			##barrel_clipping = true
			##return
#func _on_clipping_check_body_exited(body: Node2D) -> void:
	#barrel_clipping = false
