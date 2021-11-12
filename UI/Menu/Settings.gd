extends Control
class_name Settings

signal return_from_settings

onready var music_slider := $MarginContainer/CenterContainer/VBoxContainer/VBoxContainer/HSliderMusic as HSlider
onready var sound_slider := $MarginContainer/CenterContainer/VBoxContainer/VBoxContainer2/HSliderSound as HSlider
onready var cross_check := $MarginContainer/CenterContainer/VBoxContainer/VBoxContainer3/HBoxContainer/CheckBoxCross as CheckBox
onready var dir_check := $MarginContainer/CenterContainer/VBoxContainer/VBoxContainer3/HBoxContainer/CheckBoxDir as CheckBox

func refresh() -> void:
	music_slider.value = GameStatus.SETTINGS_MUSIC
	sound_slider.value = GameStatus.SETTINGS_SOUND
	cross_check.pressed = GameStatus.USE_CROSSHAIR
	dir_check.pressed = not GameStatus.USE_CROSSHAIR

func _ready() -> void:
	refresh()

func _on_HSliderMusic_value_changed(value: float) -> void:
	GameStatus.SETTINGS_MUSIC = value

func _on_HSliderSound_value_changed(value: float) -> void:
	GameStatus.SETTINGS_SOUND = value

func _on_CheckBoxDir_toggled(button_pressed: bool) -> void:
	if button_pressed:
		dir_check.disabled = true
		cross_check.disabled = false
		cross_check.pressed = false
		GameStatus.USE_CROSSHAIR = false

func _on_CheckBoxCross_toggled(button_pressed: bool) -> void:
	if button_pressed:
		cross_check.disabled = true
		dir_check.disabled = false
		dir_check.pressed = false
		GameStatus.USE_CROSSHAIR = true

func _on_TextureButton_pressed() -> void:
	visible = false
	emit_signal("return_from_settings")
