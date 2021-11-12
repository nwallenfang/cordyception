extends Control

onready var settings := $Settings as Settings

func _ready() -> void:
	settings.visible = false
	settings.refresh()
	settings.connect("return_from_settings", self, "return_from_settings")

func return_from_settings():
	$Menu.visible = true
	settings.visible = false

func _on_Play_pressed() -> void:
	get_tree().change_scene("res://Levels/Level1.tscn")

func _on_Exit_pressed() -> void:
	get_tree().quit()

func _on_Settings_pressed() -> void:
	$Menu.visible = false
	settings.visible = true
