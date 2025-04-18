extends Area2D
class_name Stroke

## A stroke is made up of Vector2s

## Simple straight, Simple curve, Complex straight, Complex curve
## Has a direction: Compass directions (straight) or CW/CCW (curve)

var stroke_points: Array[Array] = [[]]
var stroke_type

func create_stroke(substrokes: Array[Array]):
	stroke_points = substrokes
	
	# For every pair,
	# Create a collision shape 2d with the shape a SegmentShape2D
	# Shape.A is the first vector, Shape.B is the second vector
	for i in range(len(stroke_points)):
		for j in range(len(stroke_points[i]) - 1):
			var collisionshape = CollisionShape2D.new()
			var shape = SegmentShape2D.new()
			shape.a = stroke_points[i][j]
			shape.b = stroke_points[i][j+1]
			collisionshape.shape = shape
			add_child(collisionshape)

# Called when being drawn to screen. Assign this Area2D its proper Drawn collision layer.
func assign_type(type):
	stroke_type = type
	
	collision_layer = 0
	
	#match stroke_type:
		#Globals.CONNECTOR:
			#set_collision_mask_value(2, true)
		#_:
			#set_collision_mask_value(1, true)
	
	# I am looking for drawn strokes
	collision_mask = 1

func move_to_submitted():
	
	# I am no longer looking for drawn strokes
	collision_mask = 0
	
	match stroke_type:
		#Globals.CONNECTOR:
			#collision_layer = 2
		_:
			collision_layer = 1
	

func _on_area_entered(area: Area2D) -> void:
	print("hello")
	print("Collided with a: " + area.stroke_type)


func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	print("hello2")
	print("Collided with a " + area.stroke_type)
	pass # Replace with function body.
