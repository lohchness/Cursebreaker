extends Node2D

@onready var marker_actual = $MarkerActual
@onready var marker_ghost = $marker_ghost

func move_marker_actual(x, y):
	marker_actual.move_to_dest(Vector2(x,y))

func move_marker_ghost(x, y):
	marker_ghost.position = marker_actual.position
	marker_ghost.move_to_dest(Vector2(x,y))
