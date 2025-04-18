extends Node2D

var submitted_strokes: Array[Stroke] = []
var drawn_strokes: Array[Stroke] = []
var curr_stroke_points: Array[Vector2] = []

var last_pos: Vector2

var segment_max_distance = 20

var in_motion = false

const STRAIGHT_LINE_DEGREE_THRESHOLD = 20.0
const COMPLEX_STRAIGHT_DEGREE_MIN = 50.0
const COMPLEX_STRAIGHT_DEGREE_MAX = 180.0
const strokescene = preload("res://stroke.tscn")

var is_first_incant = true

func _draw():
	# Draw every submitted stroke
	for i in range(len(submitted_strokes)):
		for j in range(len(submitted_strokes[i].stroke_points)):
			for k in range(1, len(submitted_strokes[i].stroke_points[j])):
				draw_line(submitted_strokes[i].stroke_points[j][k-1], submitted_strokes[i].stroke_points[j][k], Color.BLUE_VIOLET, 5)
	
	# Draw every stroke that is pending submission
	for i in range(len(drawn_strokes)):
		for j in range(len(drawn_strokes[i].stroke_points)):
			for k in range(1, len(drawn_strokes[i].stroke_points[j])):
				draw_line(drawn_strokes[i].stroke_points[j][k-1], drawn_strokes[i].stroke_points[j][k], Color.BLACK, 5)
	
	# Draw current stroke being drawn (not submitted)
	for i in range(len(curr_stroke_points) - 1):
		draw_line(curr_stroke_points[i], curr_stroke_points[i+1], Color.BLACK, 5)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("incant"):
		
		verify_drawn_strokes()
		
		for i in range(len(drawn_strokes)):
			drawn_strokes[i].move_to_submitted()
		# Append drawn_strokes to submitted_strokes
		submitted_strokes.append_array(drawn_strokes)
		drawn_strokes = []
		queue_redraw()
		
		is_first_incant = false
	
	if event.is_action_pressed("dispel"):
		# Free strokes in drawn_strokes and empty array
		for i in range(len(drawn_strokes)):
			drawn_strokes[i].queue_free()
		drawn_strokes = []
		queue_redraw()
	
	if event is InputEventMouseButton:
		if event.is_action_pressed("brush"):
			in_motion = true
			
			last_pos = event.position
			curr_stroke_points.append(event.position)
			
		if event.is_action_released("brush"):
			in_motion = false
			
			#curr_stroke_points.append(last_pos)
			
			# Sends stored Vector2s into the Stroke class
			if len(curr_stroke_points) > 1:
				var s = classify_stroke(curr_stroke_points)
			
			curr_stroke_points = []
			
			queue_redraw()
	
	if in_motion and event is InputEventMouseMotion:
		if last_pos.distance_to(event.position) > segment_max_distance:
			last_pos = event.position
			curr_stroke_points.append(last_pos)
			
			queue_redraw()

func classify_stroke(stroke_points: Array[Vector2]) -> Stroke:
	var substrokes: Array[Array] = [[]] # Only complex straight lines will have more than 1 element
	
	print("Number of points: " + str(len(stroke_points)))
	
	var theta_zero = angle_theta(stroke_points[0], stroke_points[1])
	print("Theta Zero: " + str(theta_zero))
	
	var last_angle_difference = theta_zero
	var stroke_type = Globals.SIMPLE_STRAIGHT
	
	# Add first vector to substroke
	substrokes[-1].append(stroke_points[0])
	
	for i in range(1, len(stroke_points) - 1):
		var angle_difference = abs(angle_theta(stroke_points[i], stroke_points[i+1]) - theta_zero)
		if angle_difference >= STRAIGHT_LINE_DEGREE_THRESHOLD:
			
			var abrupt_angle_difference = angle_difference - last_angle_difference
			
			if COMPLEX_STRAIGHT_DEGREE_MIN < abrupt_angle_difference and abrupt_angle_difference < COMPLEX_STRAIGHT_DEGREE_MAX:
				# Is a complex straight. Segment this.
				
				# Add last vector to substrokes
				substrokes[-1].append(stroke_points[i])
				
				substrokes.append([])
				theta_zero = angle_theta(stroke_points[i], stroke_points[i+1])
				print("New Theta Zero: " + str(theta_zero))
				
				if stroke_type != Globals.INVALID:
					if stroke_type == Globals.SIMPLE_STRAIGHT:
						stroke_type = Globals.COMPLEX_STRAIGHT
					if stroke_type == Globals.CURVE:
						stroke_type = Globals.INVALID
				
				# new theta zero means new angle difference, for printing purposes
				angle_difference = abs(angle_theta(stroke_points[i], stroke_points[i+1]) - theta_zero)
			else:
				# Curve if otherwise.
				if stroke_type != Globals.INVALID:
					if stroke_type == Globals.SIMPLE_STRAIGHT:
						stroke_type = Globals.CURVE
					if stroke_type == Globals.COMPLEX_STRAIGHT:
						stroke_type = Globals.INVALID
		
		#print("Theta - Theta Zero: " + str(angle_difference))
		last_angle_difference = angle_difference
		
		substrokes[-1].append(stroke_points[i])
	
	# Add last vector to substrokes
	substrokes[-1].append(stroke_points[-1])
	
	if stroke_type == Globals.CURVE:
		if pixel_length(substrokes[-1]) < 150:
			stroke_type = Globals.INVALID
	
	if stroke_type == Globals.SIMPLE_STRAIGHT:
		if pixel_length(substrokes[-1]) < 200:
			stroke_type = Globals.INVALID
		if pixel_length(substrokes[-1]) < 120:
			stroke_type = Globals.CONNECTOR
	
	match stroke_type:
		Globals.SIMPLE_STRAIGHT:
			# Determine direction
			print("SIMPLE STRAIGHT")
		Globals.COMPLEX_STRAIGHT:
			print("COMPLEX STRAIGHT")
		Globals.CURVE:
			print("CURVE")
		Globals.CONNECTOR:
			print("CONNECTOR")
		_:
			print("INVALID")
	
	if stroke_type == Globals.INVALID:
		return null
	
	var stroke: Stroke = strokescene.instantiate()
	add_child(stroke)
	stroke.create_stroke(substrokes)
	stroke.assign_type(stroke_type)
	
	drawn_strokes.append(stroke)
	
	return stroke

func angle_theta(a: Vector2, b: Vector2) -> float:
	return rad_to_deg(a.angle_to_point(b))

func pixel_length(arr):
	return len(arr) * segment_max_distance

func verify_drawn_strokes():
	for stroke in drawn_strokes:
		stroke.verify(is_first_incant)
		
		#for i in range(len(stroke.stroke_points)):
			#for j in range(len(stroke.stroke_points[i]) - 1):
				#pass
