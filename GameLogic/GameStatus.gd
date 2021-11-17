extends Node

# start enemy behavior automatically (without calling trigger method or similar)
export var AUTO_ENEMY_BEHAVIOR := false

export var PLAYER_MAX_HEALTH := 4
export var PLAYER_DASH_ACC := 50000.0
export var PLAYER_PROJECTILE_DAMAGE := 7
export var PLAYER_PROJECTILE_KNOCKBACK := 70000.0
export var PLAYER_POISON_DAMAGE := 1
export var PLAYER_POISON_KNOCKBACK := 16000.0

export var ENEMY_KNOCKBACK := 20000.0

var CURRENT_HEALTH := PLAYER_MAX_HEALTH setget set_health

var CURRENT_ACT
var CURRENT_YSORT: YSort
var CURRENT_UI: UI
var CURRENT_PLAYER: Player
var CURRENT_CAMERA: ScriptedCamera
var CURRENT_CAM_REMOTE: RemoteTransform2D

var MOVE_ENABLED := true setget set_move_enabled
var SPRAY_ENABLED := false setget set_spray_enabled
var SHOOT_ENABLED := false setget set_shoot_enabled
var DASH_ENABLED := false setget set_dash_enabled
var AIMER_VISIBLE := true setget set_aimer_visible
var HEALTH_VISIBLE := false setget set_health_visible

func set_move_enabled(enabled: bool) -> void:
	MOVE_ENABLED = enabled

func set_spray_enabled(enabled: bool) -> void:
	SPRAY_ENABLED = enabled

func set_shoot_enabled(enabled: bool) -> void:
	SHOOT_ENABLED = enabled
	CURRENT_UI.show_shoot = enabled

func set_dash_enabled(enabled: bool) -> void:
	DASH_ENABLED = enabled
	CURRENT_UI.show_dash = enabled

func set_aimer_visible(vis: bool) -> void:
	AIMER_VISIBLE = vis
	CURRENT_PLAYER.aimer.visible = vis

func set_health_visible(vis: bool) -> void:
	HEALTH_VISIBLE = vis
	CURRENT_UI.show_health = vis

func set_health(new_health:int):
	CURRENT_HEALTH = clamp(new_health, 0, PLAYER_MAX_HEALTH)
	CURRENT_UI.set_hearts(new_health)
	if CURRENT_HEALTH == 0:
		GameEvents.trigger_event("player_died")


signal input_device_changed
var CONTROLLER_USED := false

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("any_controller_input"):
		if !CONTROLLER_USED:
			CONTROLLER_USED = true
			emit_signal("input_device_changed")
	if Input.is_action_pressed("any_keyboard_input"):
		if CONTROLLER_USED:
			CONTROLLER_USED = false
			emit_signal("input_device_changed")

var MOUSE_CAPTURE : bool = false setget set_mouse_capture

func set_mouse_capture(capture: bool) -> void:
	MOUSE_CAPTURE = capture
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if MOUSE_CAPTURE else Input.MOUSE_MODE_VISIBLE)

func _input(event: InputEvent) -> void:
	# browsers only allow mouse capture after the user has interacted with the 
	# game, so the mouse mode has to be set in _input
	# see https://docs.godotengine.org/en/stable/getting_started/workflow/export/exporting_for_web.html#full-screen-and-mouse-capture
	if MOUSE_CAPTURE:
		if not Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

var SETTINGS_MUSIC : float = 0.5 setget set_music_volume
var SETTINGS_SOUND : float = 0.5 setget set_sound_volume
const SFX_BUS_INDEX = 1
const MUSIC_BUS_INDEX = 2
var USE_CROSSHAIR : bool = false

func set_music_volume(volume: float):
	var index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(index, linear2db(volume))
	SETTINGS_MUSIC = volume
	
func set_sound_volume(volume: float):
	var index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(index, linear2db(volume))
	SETTINGS_SOUND = volume
