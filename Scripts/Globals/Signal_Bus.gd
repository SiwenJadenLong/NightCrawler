extends Node

signal newobject(object_position : Vector2, object : Node)

#Weapon signals:
signal update_magazines(current_mag: int, inventory_mags : Array[int])
signal updateroundcount(current_roundcount : int)
signal show_magazines
signal hide_magazines
signal pass_max_capacity
