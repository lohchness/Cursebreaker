extends Label

func change_text(str):
	text = str
	$Timer.start()

func _on_timer_timeout() -> void:
	text = ""
