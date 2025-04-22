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
const strokescene = preload("res://scenes/stroke.tscn")

@onready var tooltip = $TooltipHelp

var polyphone_player: AudioStreamPlayer2D
var polyphonic: AudioStreamPlaybackPolyphonic

@export var hit_sound: AudioStream
@export var slide_sound: Array[AudioStream]
@onready var slide_cd = $SlideSoundCooldown

var is_first_incant = true
var verify_first_incant = true

signal submit_drawn_stroke
signal new_drawn_stroke

func _ready() -> void:
	polyphone_player = $AudioStreamPlayer2D
	polyphone_player.play() # need to play to get polyphonic stream playback
	polyphonic = polyphone_player.get_stream_playback()

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



func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	
	
	if event is InputEventMouseButton:
		if event.is_action_pressed("brush"):
			in_motion = true
			
			last_pos = event.position
			curr_stroke_points.append(event.position)
			
			play_sound(hit_sound)
			
		if event.is_action_released("brush"):
			brush_release()
	
	if in_motion and event is InputEventMouseMotion:
		#if slide_cd.is_stopped():
			#play_sound(slide_sound.pick_random())
			#slide_cd.start()
		
		if last_pos.distance_to(event.position) > segment_max_distance:
			last_pos = event.position
			curr_stroke_points.append(last_pos)
			
			if slide_cd.is_stopped():
				play_sound(slide_sound.pick_random())
				slide_cd.start()
			
			queue_redraw()


func _on_mouse_exited() -> void:
	brush_release()

func brush_release():
	in_motion = false
			
	#curr_stroke_points.append(last_pos)
	
	# Sends stored Vector2s into the Stroke class
	if len(curr_stroke_points) > 1:
		var s = classify_stroke(curr_stroke_points)
	
	curr_stroke_points = []
	
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dispel"):
		dispel()
	
	if event.is_action_pressed("incant"):
		incant()

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
						handle_stroke_error("Your curve is too sharp!")
						stroke_type = Globals.INVALID
				
				# new theta zero means new angle difference, for printing purposes
				angle_difference = abs(angle_theta(stroke_points[i], stroke_points[i+1]) - theta_zero)
			else:
				# Curve if otherwise.
				if stroke_type != Globals.INVALID:
					if stroke_type == Globals.SIMPLE_STRAIGHT:
						stroke_type = Globals.CURVE
					if stroke_type == Globals.COMPLEX_STRAIGHT:
						handle_stroke_error("Your sharp is too curvy!")
						stroke_type = Globals.INVALID
		
		#print("Theta - Theta Zero: " + str(angle_difference))
		last_angle_difference = angle_difference
		
		substrokes[-1].append(stroke_points[i])
	
	# Add last vector to substrokes
	substrokes[-1].append(stroke_points[-1])
	
	if stroke_type == Globals.CURVE:
		if pixel_length(substrokes[-1]) < 50:
			stroke_type = Globals.INVALID
			handle_stroke_error("Your curve is too short!")
	
	if stroke_type == Globals.SIMPLE_STRAIGHT:
		if pixel_length(substrokes[-1]) >= 120: # and pixel_length(substrokes[-1]) < 200:
			stroke_type = Globals.INVALID
			handle_stroke_error("Your connector is too long!")
		elif pixel_length(substrokes[-1]) < 120:
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
	
	stroke.stroke_error.connect(Callable(self, "handle_stroke_error"))
	if stroke_type == Globals.COMPLEX_STRAIGHT or stroke_type == Globals.CURVE:
		new_drawn_stroke.emit()
	
	return stroke

func angle_theta(a: Vector2, b: Vector2) -> float:
	return rad_to_deg(a.angle_to_point(b))

func pixel_length(arr):
	return len(arr) * segment_max_distance

func verify_drawn_strokes():
	var has_error = false
	for stroke in drawn_strokes:
		var s = stroke.verify(is_first_incant)
		
		if s and has_error == false:
			has_error = true
		if not s:
			is_first_incant = false
		#for i in range(len(stroke.stroke_points)):
			#for j in range(len(stroke.stroke_points[i]) - 1):
				#pass
	return has_error

func incant():
	if (len(drawn_strokes) > 0):
		if verify_drawn_strokes():
			# There is an error in drawn strokes
			dispel()
			
			# If it was first incant, then make is_first_incant true again
			if verify_first_incant:
				is_first_incant = true
		else:
			
			for i in range(len(drawn_strokes)):
				drawn_strokes[i].move_to_submitted()
			# Append drawn_strokes to submitted_strokes
			submitted_strokes.append_array(drawn_strokes)
			
			verify_first_incant = false
			is_first_incant = false
			
			submit_drawn_stroke.emit()
		
		drawn_strokes = []
		queue_redraw()

func dispel():
# Free strokes in drawn_strokes and empty array
	for i in range(len(drawn_strokes)):
		drawn_strokes[i].queue_free()
	drawn_strokes = []
	queue_redraw()
	
	new_drawn_stroke.emit()

func handle_stroke_error(val: String):
	tooltip.change_text(val)

func play_sound(sound: AudioStream):
	polyphonic.play_stream(sound)
