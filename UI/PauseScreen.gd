extends Control

onready var resume_button := $MarginContainer/CenterContainer/VBoxContainer/CenterContainer/VBoxContainer/ResumeButton as TextureButton
onready var settings_button := $MarginContainer/CenterContainer/VBoxContainer/CenterContainer/VBoxContainer/SettingsButton as TextureButton
onready var exit_button := $MarginContainer/CenterContainer/VBoxContainer/CenterContainer/VBoxContainer/ExitButton as TextureButton

func _ready() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().paused = not get_tree().paused
		visible = not visible
		GameStatus.MOUSE_CAPTURE = not visible

func _on_ExitButton_pressed() -> void:
	get_tree().quit()

func _on_ResumeButton_pressed() -> void:
	get_tree().paused = false
	visible = false
	GameStatus.MOUSE_CAPTURE = true
