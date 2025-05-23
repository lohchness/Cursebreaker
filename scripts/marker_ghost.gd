extends CharacterBody2D

var speed = 200

var direction = Vector2(0,0)
var remaining_distance = 0

# This ghost travels the path that marker actual will go without 
# colliding with targets. This is so that the player does not 
# need to guess where the marker will end up at the end.
# On stroke creation, Map will reset this ghost position to 
# the marker actual, then move via trajectory

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
