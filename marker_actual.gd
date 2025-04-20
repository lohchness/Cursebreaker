extends CharacterBody2D

func _physics_process(delta: float) -> void:
	
	velocity = Vector2(0, -100)
	move_and_slide()
