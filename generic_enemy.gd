extends CharacterBody2D


const SPEED : int = 250
var enemy_state : enemy_states
enum enemy_states {
	patroling,
	attacking,
	searching,
	covering,
}

func follow_next_line():
	

func _physics_process(delta: float) -> void:
	pass
