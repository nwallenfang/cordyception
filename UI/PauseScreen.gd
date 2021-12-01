extends Control

onready var resume_button := $MarginContainer/CenterContainer/VBoxContainer/CenterContainer/VBoxContainer/ResumeButton as TextureButton
onready var settings_button := $MarginContainer/CenterContainer/VBoxContainer/CenterContainer/VBoxContainer/SettingsButton as TextureButton
onready var exit_button := $MarginContainer/CenterContainer/VBoxContainer/CenterContainer/VBoxContainer/ExitButton as TextureButton
onready var settings := $Settings as Settings

func _ready() -> void:
	visible = false
	settings.visible = false
	settings.connect("return_from_settings", self, "return_from_settings")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().paused = not get_tree().paused
		visible = not visible
		$MarginContainer.visible = visible
		settings.visible = false
		GameStatus.MOUSE_CAPTURE = not visible
		Input.set_custom_mouse_cursor(null)

func _on_ExitButton_pressed() -> void:
	get_tree().quit()

func _on_ResumeButton_pressed() -> void:
	get_tree().paused = false
	visible = false
	GameStatus.MOUSE_CAPTURE = true
	Input.set_custom_mouse_cursor(GameStatus.CURSOR_INVIS)

func _on_SettingsButton_pressed() -> void:
	$MarginContainer.visible = false
	settings.visible = true
	settings.refresh()

func return_from_settings():
	$MarginContainer.visible = true
	settings.visible = false
