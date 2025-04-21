extends CharacterBody2D

var speed = 200

var direction = Vector2(.5,1)
var remaining_distance = 1000

func _physics_process(delta: float) -> void:
	if remaining_distance > 0:
		velocity = direction * speed
		remaining_distance -= speed * delta
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

func move_to_dest(dest: Vector2):
	# Given a Vector2 destination:
	# Calculate distance from current position to destination
	# Calculate direction
	
	remaining_distance = dest.length()
	direction = dest.normalized()
