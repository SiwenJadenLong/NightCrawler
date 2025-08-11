extends Area2D




func _on_body_entered(body: Node2D) -> void:
	if body.has_method("damage"):
		body.damage(9999)
