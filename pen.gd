extends Node2D

var all_strokes: Array = []
var curr_stroke_points: Array[Vector2] = []

var last_pos: Vector2

var segment_max_distance = 20

var in_motion = false

enum {DEFAULT, SIMPLE_STRAIGHT, COMPLEX_STRAIGHT, CURVE, CONNECTOR, INVALID}
const STRAIGHT_LINE_DEGREE_THRESHOLD = 20.0
const COMPLEX_STRAIGHT_DEGREE_MIN = 50.0
const COMPLEX_STRAIGHT_DEGREE_MAX = 180.0

func _draw():
	# Draw every submitted stroke
	for i in range(len(all_strokes)):
		for j in range(len(all_strokes[i].stroke_points)):
			for k in range(1, len(all_strokes[i].stroke_points[j])):
				draw_line(all_strokes[i].stroke_points[j][k-1], all_strokes[i].stroke_points[j][k], Color.BLACK, 5)
	
	# Draw current stroke being drawn (not submitted)
	for i in range(len(curr_stroke_points) - 1):
		draw_line(curr_stroke_points[i], curr_stroke_points[i+1], Color.BLACK, 5)


func _input(event: InputEvent) -> void:
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
				if s != null:
					all_strokes.append(s)
			
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
	var stroke_type = SIMPLE_STRAIGHT
	
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
				if stroke_type == SIMPLE_STRAIGHT:
					stroke_type = COMPLEX_STRAIGHT
				if stroke_type == CURVE:
					stroke_type = INVALID
				
				# new theta zero means new angle difference, for printing purposes
				angle_difference = abs(angle_theta(stroke_points[i], stroke_points[i+1]) - theta_zero)
			else:
				# Curve if otherwise.
				if stroke_type == SIMPLE_STRAIGHT:
					stroke_type = CURVE
				if stroke_type == COMPLEX_STRAIGHT:
					stroke_type = INVALID
		
		print("Theta - Theta Zero: " + str(angle_difference))
		last_angle_difference = angle_difference
		
		substrokes[-1].append(stroke_points[i])
	
	# Add last vector to substrokes
	substrokes[-1].append(stroke_points[-1])
	
	if stroke_type == SIMPLE_STRAIGHT:
		if len(substrokes[-1]) < 10:
			stroke_type = INVALID
		if len(substrokes[-1]) < 7:
			stroke_type = CONNECTOR
	
	match stroke_type:
		SIMPLE_STRAIGHT:
			# Determine direction
			print("SIMPLE STRAIGHT")
		COMPLEX_STRAIGHT:
			print("COMPLEX STRAIGHT")
		CURVE:
			print("CURVE")
		CONNECTOR:
			print("CONNECTOR")
		_:
			print("INVALID")
	
	if stroke_type == INVALID:
		return null
	
	var stroke: Stroke = Stroke.new()
	stroke.create_stroke(substrokes)
	
	return stroke

func angle_theta(a: Vector2, b: Vector2) -> float:
	return rad_to_deg(a.angle_to_point(b))
