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
	
	match stroke_type:
		Globals.CONNECTOR:
			# As a connector I am looking to connect to strokes
			collision_mask = 1
		_:
			# As a stroke I am looking to connect to connectors
			collision_mask = 2

func move_to_submitted():
	
	# I am no longer looking for any strokes
	collision_mask = 0
	
	match stroke_type:
		Globals.CONNECTOR:
			collision_layer = 2
		_:
			collision_layer = 1
	

func _on_area_entered(area: Area2D) -> void:
	var output
	match area.stroke_type:
		Globals.CONNECTOR:
			output = "connector"
		Globals.SIMPLE_STRAIGHT:
			output = "simple straight"
		Globals.COMPLEX_STRAIGHT:
			output = "complex straight"
		Globals.CURVE:
			output = "curve"
			
	print_debug("Collided with a " + output)
