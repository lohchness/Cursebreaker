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
	
	
	pass # Replace with function body.
