extends Node2D
class_name Stroke

## A stroke is made up of Vector2s

## Simple straight, Simple curve, Complex straight, Complex curve
## Has a direction: Compass directions (straight) or CW/CCW (curve)

var stroke_type

var stroke_points: Array[Array] = [[]]

func create_stroke(substrokes: Array[Array]):
	stroke_points = substrokes
	
