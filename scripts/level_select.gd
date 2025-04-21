extends Control


func _ready() -> void:
	modulate = Color(0, 0, 0, 255)

func _physics_process(delta: float) -> void:
	if modulate.r < 1:
		modulate.r += delta
		modulate.g += delta
		modulate.b += delta


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/tutorial_page_1.tscn")

func _on_level_1_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Level1.tscn")

func _on_level_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Level2.tscn")

func _on_level_3_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Level3.tscn")

func _on_level_4_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Level4.tscn")

func _on_level_5_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Level5.tscn")
