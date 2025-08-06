extends Node2D
class_name held_item

@onready var item_held_sprite: Sprite2D = $"item held sprite"

@export var item_name = "NO NAME"
@export var item_image : Texture2D = preload("res://icon.svg")
@export var item_held_texture : Texture2D = preload("res://images/Items/mk18 top view.png")
@export var position_offset : Vector2 
var total_ammo : int
var magazine_capacity : int

func aim_exact_point_at_cursor():
	look_at(get_global_mouse_position())
	
