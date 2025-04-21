extends Control

var move = false
@onready var level_select

@onready var origcolor

func _ready() -> void:
	origcolor = modulate

func _physics_process(delta: float) -> void:
	if move:
		position += Vector2(0,-500) * delta
		#modulate = lerp(modulate, Color(origcolor.r, origcolor.g, origcolor.b, 0), 5 * delta)
		#modulate.a -= delta
		modulate.r -= delta
		modulate.g -= delta
		modulate.b -= delta
	
	if modulate.r <= 0:
		get_tree().change_scene_to_file("res://scenes/level_select.tscn")


func _on_texture_button_pressed() -> void:
	move = true
