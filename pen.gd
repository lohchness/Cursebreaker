extends Node2D

var all_strokes: Array = []
var curr_stroke_points: Array[Vector2] = []

var last_pos: Vector2

var segment_max_distance = 20

var in_motion = false

func _draw():
	# Draw every submitted stroke
	for i in range(len(all_strokes)):
		for j in range(1, len(all_strokes[i].stroke_points)):
			draw_line(all_strokes[i].stroke_points[j-1], all_strokes[i].stroke_points[j], Color.BLACK, 5)
	
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
			
			if len(curr_stroke_points) > 1:
				var stroke = Stroke.new()
				stroke.stroke_points = curr_stroke_points
				stroke.classify_stroke()
				all_strokes.append(stroke)
			
			curr_stroke_points = []
	
	if in_motion and event is InputEventMouseMotion:
		if last_pos.distance_to(event.position) > segment_max_distance:
			last_pos = event.position
			curr_stroke_points.append(last_pos)
			
			queue_redraw()
