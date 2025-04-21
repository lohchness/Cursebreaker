extends Control

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("brush"):
		get_tree().change_scene_to_file("res://scenes/tutorial_page_3.tscn")
