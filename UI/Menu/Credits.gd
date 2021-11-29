extends Control
class_name Credits

signal return_from_credits

func _on_TextureButton_pressed() -> void:
	visible = false
	emit_signal("return_from_credits")
