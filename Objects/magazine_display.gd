extends HBoxContainer

var existing_current_mag : int
var existing_inventory_mags : Array[int]
var magazine_capacity : int

const MAG_ICON = preload("res://Objects/UI/mag icon.tscn")
@onready var rd_count: Label = $"RD Count"
@onready var current_mag: TextureProgressBar = $"RD Count/current_mag"

func _ready() -> void:
	SignalBus.update_magazines.connect(update_magazines)
	SignalBus.updateroundcount.connect(update_roundcount)
	SignalBus.hide_magazines.connect(fade_away)
	SignalBus.show_magazines.connect(fade_in)
	SignalBus.pass_max_capacity.connect(set_max_capacity)
	await SignalBus.pass_max_capacity
	current_mag.max_value = magazine_capacity

func update_roundcount(current_roundcount : int):
	current_mag.value = current_roundcount
	rd_count.text = str(int(current_mag.value))

func update_magazines(current_roundcount : int, inventory_mags : Array[int], mag_in_gun : bool):
	clear_magazines()
	fade_in()
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
	fade_tween.tween_property(self, "modulate:a", 0, 0.5)
	await fade_tween.finished

func fade_in():
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 1, 0.5)
	await fade_tween.finished

func set_max_capacity(max_roundcount):
	magazine_capacity = max_roundcount
