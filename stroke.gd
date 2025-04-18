extends StaticBody2D
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
