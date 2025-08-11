extends Node

#Main Signals
signal load_level(level : String)

#Level signals
signal newobject(object_position : Vector2, object : Node)

#Weapon signals:
signal update_magazines(current_mag: int, inventory_mags : Array[int])
signal updateroundcount(current_roundcount : int)
signal show_magazines
signal hide_magazines
signal pass_max_capacity

#Gameplay Signals:
signal player_death()

signal winconditioncheck
signal win
