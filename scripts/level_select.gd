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
