extends Node2D

# Level manages the map and its marker(s):
#  - Moves the map>marker ghost to its position
#  - Moves the map>marker actual to marker ghost?
# Holds data for all the targets the marker actual has to hit
# Holds level name

@export var levelname: String = ""
@onready var whiteboard = $Whiteboard
@onready var map = $Map


func _on_whiteboard_submit_drawn_stroke() -> void:
	
	var trajectory = calculate_trajectory()
	
	map.move_marker_actual(trajectory.x, trajectory.y)


func _on_incant_button_pressed() -> void:
	whiteboard.incant()

func _on_dispel_button_pressed() -> void:
	whiteboard.dispel()

func _on_reset_button_pressed() -> void:
	get_tree().reload_current_scene()

func calculate_trajectory():
	# Called just after whiteboard submission
	# Iterate through each drawn stroke
	#  If connector, nothing
	#  Complex straight: length of stroke is how far it goes right
	#  Curve: length of stroke is how far it goes left
	#  Accumulate total width and height
	# Total width and height: 
	#  do a ratio? if close to 0.9 then it is a square - does not move up or down
	#  Difference in width and height is how far it goes up and down
	# Send this data to Map
	
	var total_width = 0
	var total_height = 0
	var length_sharp = 0
	var length_curve = 0
	
	for stroke: Stroke in whiteboard.drawn_strokes:
		if stroke.stroke_type == Globals.CONNECTOR:
			continue
		
		if stroke.stroke_type == Globals.COMPLEX_STRAIGHT:
			length_sharp += stroke.length
		elif stroke.stroke_type == Globals.CURVE:
			length_curve += stroke.length
		
		total_width += stroke.stroke_width
		total_height += stroke.stroke_height
	
	var total_x = length_sharp - length_curve
	var total_y = total_width - total_height
	
	total_x *= .4
	total_y *= .4
	
	return Vector2(total_x, total_y)
