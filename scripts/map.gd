extends Node2D

@onready var marker_actual = $MarkerActual

func move_marker_actual(x, y):
	marker_actual.move_to_dest(Vector2(x,y))
