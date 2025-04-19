extends Area2D
class_name Stroke

## A stroke is made up of Vector2s

## Simple straight, Simple curve, Complex straight, Complex curve
## Has a direction: Compass directions (straight) or CW/CCW (curve)

var stroke_points: Array[Array] = [[]]
var stroke_type

var connected_to: Array[Stroke] = []

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

func verify():
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
			
			else:
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
		pass

	return false
