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

var CURRENT_YSORT: YSort
var CURRENT_UI: UI
var CURRENT_PLAYER: Player

func set_health(new_health:int):
	CURRENT_HEALTH = clamp(new_health, 0, PLAYER_MAX_HEALTH)
	CURRENT_UI.get_node("HealthUI").set_hearts(new_health)
	

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

var SETTINGS_MUSIC : float = 0.5
var SETTINGS_SOUND : float = 0.5
var USE_CROSSHAIR : bool = false
