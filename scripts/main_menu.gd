extends Control

var move = false
@onready var level_select

@onready var origcolor

func _ready() -> void:
	origcolor = modulate

func _physics_process(delta: float) -> void:
	if move:
		position += Vector2(0,-500) * delta
		modulate = lerp(modulate, Color(origcolor.r, origcolor.g, origcolor.b, 0), 5 * delta)
	
	if modulate == Color(255, 255, 255, 0):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_texture_button_pressed() -> void:
	move = true
