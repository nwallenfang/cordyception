extends Control

onready var settings := $Settings as Settings
onready var credits := $Credits as Credits

func _ready() -> void:
	settings.visible = false
	settings.refresh()
	settings.connect("return_from_settings", self, "return_from_settings")
	credits.visible = false
	credits.connect("return_from_credits", self, "return_from_credits")

func return_from_settings():
	$Menu.visible = true
	settings.visible = false

func _on_Play_pressed() -> void:
	#get_tree().change_scene("res://Levels/Act1.tscn")
	$Cutscene.start_movement()
	$Menu.visible = false
	yield(get_tree().create_timer(3), "timeout")
	$MusicTween.interpolate_property($TitleMusic, "volume_db", $TitleMusic.volume_db, -80, 8)
	$MusicTween.start()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_Exit_pressed() -> void:
	get_tree().quit()

func _on_Settings_pressed() -> void:
	$Menu.visible = false
	settings.visible = true

func _on_Credits_pressed() -> void:
	$Menu.visible = false
	credits.visible = true

func return_from_credits():
	$Menu.visible = true
	settings.visible = false
