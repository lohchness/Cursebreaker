extends Control

@onready var texturerect3 = $TextureRect3

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("brush"):
		if texturerect3.visible == false:
			texturerect3.visible = true
		else:
			get_tree().change_scene_to_file("res://scenes/tutorial_page_1.tscn")
