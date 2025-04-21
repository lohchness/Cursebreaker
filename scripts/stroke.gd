extends Area2D
class_name Stroke

## A stroke is made up of Vector2s

## Simple straight, Simple curve, Complex straight, Complex curve
## Has a direction: Compass directions (straight) or CW/CCW (curve)

var stroke_points: Array[Array] = [[]]
var stroke_type
var stroke_width = 0;
var stroke_height = 0;
var length = 0

var connected_to: Array[Stroke] = []

func create_stroke(substrokes: Array[Array]):
	stroke_points = substrokes
	var MaxX = 0
	var MinX = 0
	var MaxY = 0
	var MinY = 0
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
			
			# for every pair, add up the magnitude of the 2 Vector2s.
			length += stroke_points[i][j].distance_to(stroke_points[i][j+1])
	
	# Go through list again, and get max/min x/y
	
	# Should work as it is guaranteed that a created stroke has at least 1 substroke
	MaxX = stroke_points[0][0].x
	MinX = stroke_points[0][0].x
	MaxY = stroke_points[0][0].y
	MinY = stroke_points[0][0].y
	
	for i in range(len(stroke_points)):
		for j in range(len(stroke_points[i])):
			# set max/min x and y 
			MaxX = maxf(MaxX,stroke_points[i][j].x)
			MinX = minf(MinX,stroke_points[i][j].x)
			MaxY = maxf(MaxY,stroke_points[i][j].y)
			MinY = minf(MinY,stroke_points[i][j].y)
	
	print(MaxX,", ",MinX)
	print(MaxY,", ",MinY)
	stroke_width = MaxX-MinX
	stroke_height = MaxY-MinY

# Called when being drawn to screen. Assign this Stroke its proper Drawn collision layer.
func assign_type(type):
	stroke_type = type
	
	# All strokes look for everything. Correctness checked in verification stage
	collision_mask = 1|2|4|8
	
	match stroke_type:
		Globals.CONNECTOR:
			## As a drawn connector I am looking to connect to strokes
			#collision_mask = 1 | 4
			
			collision_layer = 8
		_:
			## As a drawn stroke I am looking to connect to connectors
			#collision_mask = 2 | 8
			
			collision_layer = 4
	
	update_name()

func move_to_submitted():
	
	# I am no longer looking for any strokes
	collision_mask = 0
	
	match stroke_type:
		Globals.CONNECTOR:
			collision_layer = 2
		_:
			collision_layer = 1
	
	update_name()

func _on_area_entered(area: Area2D) -> void:
	print(" collided with a " + area.name)
	
	# Connectors must hit 1 submitted stroke or 1 drawn stroke (may move to validation stage)
	
	connected_to.append(area)

func update_name():
	var output = ""
	if collision_layer == 1 or collision_layer == 2:
		output += "Submitted "
	elif collision_layer == 4 or collision_layer == 8:
		output += "Drawn "
	else:
		output += "Error"
	
	match stroke_type:
		Globals.CONNECTOR:
			output += "connector"
		Globals.SIMPLE_STRAIGHT:
			output += "simple straight"
		Globals.COMPLEX_STRAIGHT:
			output += "complex straight"
		Globals.CURVE:
			output += "curve"
	
	set_name(output)

func verify(first):
	# Return true if error
	if stroke_type == Globals.CONNECTOR:
		# Connectors:
		#  - Cannot have no connections or have 1 connection
		#     - Can only have at least 2 connections
		#  - Cannot have another drawn or submitted connector
		#  - Must hit at least 2 drawn strokes OR at least 1 submitted and at least 1 drawn stroke
		
		if len(connected_to) < 2:
			print("ERROR: Connector has less than 2 connections")
			return true
		
		var submitted_stroke_count = 0
		var drawn_stroke_count = 0
		
		for i in connected_to:
			if i.stroke_type == Globals.CONNECTOR:
				print("ERROR: Connector connected to another connector")
				return true
			
			# Check if i is a drawn or submitted stroke
			if i.collision_layer == 1:
				submitted_stroke_count += 1
			if i.collision_layer == 4:
				drawn_stroke_count += 1
		
		if submitted_stroke_count > 0 and drawn_stroke_count == 0:
			print("ERROR: Connector only connected to submitted strokes")
			return true
		
	else:
		# Strokes:
		#  - Cannot have another drawn or submitted stroke
		#  - Can only have drawn connectors
		#  - Must have at least 1 connection if it is not the first incant
		#  - Cannot have submitted connectors
		
		if not first:
			if len(connected_to) == 0:
				print("ERROR: Not first incant, stroke must have a connector")
				return true
		
		for i in connected_to:
			if i.stroke_type != Globals.CONNECTOR:
				print("ERROR: Stroke connected to another stroke")
				return true
			
			# Check if i is a submitted connector
			if i.collision_layer == 2:
				print("ERROR: Stroke connected to submitted connector")
				return true

	return false
