extends HBoxContainer

var existing_current_mag : int
var existing_inventory_mags : Array[int]
var magazine_capacity : int

@export var fade_timeout : float = 2
const MAG_ICON = preload("res://Objects/UI/mag icon.tscn")

@onready var rd_count: Label = $"RD Count"
@onready var current_mag: TextureProgressBar = $"RD Count/current_mag"
@onready var magazine_fade_timeout: Timer = $"Magazine Fade Timeout"


func _ready() -> void:
	SignalBus.update_magazines.connect(update_magazines)
	SignalBus.updateroundcount.connect(update_roundcount)
	
	SignalBus.show_magazines.connect(fade_in)
	
	SignalBus.pass_max_capacity.connect(set_max_capacity)
	await SignalBus.pass_max_capacity
	current_mag.max_value = magazine_capacity

func update_roundcount(current_roundcount : int):
	current_mag.value = current_roundcount
	rd_count.text = str(int(current_mag.value))

func update_magazines(current_roundcount : int, inventory_mags : Array[int], mag_in_gun : bool):
	clear_magazines()
	update_roundcount(current_roundcount)
	for inv_mag in inventory_mags:
		var new_mag = MAG_ICON.instantiate()
		new_mag.max_value = magazine_capacity
		new_mag.value = inv_mag
		add_child(new_mag)
	if mag_in_gun:
		current_mag.show()
	else:
		current_mag.hide()
	
func clear_magazines():
	for mag in get_children():
		if mag.is_in_group("mag_icon"):
			mag.queue_free()

func fade_away():
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0, 0.25).set_ease(Tween.EASE_OUT)
	await fade_tween.finished
	fade_tween.kill()

func fade_in():
	magazine_fade_timeout.start(2.5)
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 1, 0.5).set_ease(Tween.EASE_IN)
	await fade_tween.finished
	fade_tween.kill()

func set_max_capacity(max_roundcount):
	magazine_capacity = max_roundcount



func _on_magazine_fade_timeout_timeout() -> void:
	fade_away()
