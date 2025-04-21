extends Area2D

signal target_hit

func _on_body_entered(body: Node2D) -> void:
	print("Target found")
	target_hit.emit()
	queue_free()
