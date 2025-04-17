extends Node2D
class_name Stroke

## A stroke is made up of Vector2s

## Simple straight, Simple curve, Complex straight, Complex curve
## Has a direction: Compass directions (straight) or CW/CCW (curve)

enum {SIMPLE_STRAIGHT, COMPLEX_STRAIGHT, CURVE, CONNECTOR}
var stroke_type = SIMPLE_STRAIGHT

var stroke_points: Array[Vector2] = []

const STRAIGHT_LINE_THRESHOLD = 20.0



func classify_stroke():
	print("Number of points: " + str(len(stroke_points)))
	
	var theta_zero = angle_theta(stroke_points[0], stroke_points[1])
	print("Theta Zero: " + str(theta_zero))
	
	
	for i in range(1, len(stroke_points) - 1):
		var angle_difference = abs(theta_zero - angle_theta(stroke_points[i], stroke_points[i+1]))
		if angle_difference >= STRAIGHT_LINE_THRESHOLD:
			#print("changed type")
			stroke_type = COMPLEX_STRAIGHT
			# Complex straight line or curve
			pass
		print(angle_difference)
	
	match stroke_type:
		SIMPLE_STRAIGHT:
			# Determine direction
			print("STRAIGHT LINE")
			pass
		_:
			print("NOT")

func angle_theta(a: Vector2, b: Vector2) -> float:
	return rad_to_deg(a.angle_to_point(b))
	#return rad_to_deg(a.angle_to(b))
