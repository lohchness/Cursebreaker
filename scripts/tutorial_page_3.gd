extends Control

@onready var texturerect2 = $TextureRect2

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("brush"):
		if texturerect2.visible == false:
			texturerect2.visible = true
		else:
			get_tree().change_scene_to_file("res://scenes/level_select.tscn")
