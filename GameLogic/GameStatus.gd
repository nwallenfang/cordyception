extends Node

# start enemy behavior automatically (without calling trigger method or similar)
export var AUTO_ENEMY_BEHAVIOR := false
var const_delta = 1.0 / 60
export var PLAYER_MAX_HEALTH := 5
export var PLAYER_DASH_ACC := 59000.0
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
var BOSS_HEALTH_VISIBLE := false setget set_boss_health_visible
var PLAYERHURT_ENABLED := true

var SETTINGS_MUSIC : float = 0.5 setget set_music_volume
var SETTINGS_SOUND : float = 0.5 setget set_sound_volume
const SFX_BUS_INDEX = 1
const MUSIC_BUS_INDEX = 2
var USE_CROSSHAIR : bool = true setget set_use_crosshair

var STARTING_CUTSCENE_HAS_PLAYED := false

var EASY_MODE := false setget set_easy_mode

func set_easy_mode(mode: bool):
	EASY_MODE = mode
	PLAYER_POISON_DAMAGE = 2 if mode else 1
	PLAYER_PROJECTILE_DAMAGE = 14 if mode else 7

signal start_spray
signal stop_spray

func _ready():
	randomize()

func set_move_enabled(enabled: bool) -> void:
	MOVE_ENABLED = enabled

func set_spray_enabled(enabled: bool) -> void:
	SPRAY_ENABLED = enabled
	CURRENT_UI.show_spray = enabled

func set_shoot_enabled(enabled: bool) -> void:
	SHOOT_ENABLED = enabled
	CURRENT_UI.show_shoot = enabled

func set_dash_enabled(enabled: bool) -> void:
	DASH_ENABLED = enabled
	CURRENT_UI.show_dash = enabled

func set_aimer_visible(vis: bool) -> void:
	AIMER_VISIBLE = vis
	if !USE_CROSSHAIR:
		CURRENT_PLAYER.aimer.visible = vis
	else:
		Input.set_custom_mouse_cursor(load("res://UI/cross.png") if vis else null)
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED if vis else Input.MOUSE_MODE_CAPTURED)

func set_use_crosshair(use: bool) -> void:
	USE_CROSSHAIR = use
	if CURRENT_PLAYER != null:
		if is_instance_valid(CURRENT_PLAYER):
			CURRENT_PLAYER.aimer.visible = not use

func set_health_visible(vis: bool) -> void:
	HEALTH_VISIBLE = vis
	CURRENT_UI.show_health = vis
	
func set_boss_health_visible(vis: bool) -> void:
	BOSS_HEALTH_VISIBLE = vis
	CURRENT_UI.set_show_boss_health(vis)

func set_health(new_health:int):
	CURRENT_HEALTH = clamp(new_health, 0, PLAYER_MAX_HEALTH)
	CURRENT_UI.set_hearts(new_health)
	if CURRENT_HEALTH == 0:
		GameEvents.trigger_event("player_died")


signal input_device_changed
var CONTROLLER_USED := false 
var crosshair_previously_on_keyboard := true

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("any_controller_input"):
		if !CONTROLLER_USED:
			CONTROLLER_USED = true
			crosshair_previously_on_keyboard = USE_CROSSHAIR
			set_use_crosshair(false)
			emit_signal("input_device_changed")
	if Input.is_action_pressed("any_keyboard_input"):
		if CONTROLLER_USED:
			CONTROLLER_USED = false
			set_use_crosshair(crosshair_previously_on_keyboard)
			emit_signal("input_device_changed")

var MOUSE_CAPTURE : bool = false setget set_mouse_capture

func set_mouse_capture(capture: bool) -> void:
	MOUSE_CAPTURE = capture
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if MOUSE_CAPTURE else Input.MOUSE_MODE_VISIBLE)

# signal with boolean argument
#signal change_controller_used(use_controller)
#func set_controller_used(use_controller: bool):
#	var previously = GameStatus.CONTROLLER_USED
#	if previously != use_controller:
#		emit_signal("change_controller_used", use_controller)
#	GameStatus.CONTROLLER_USED

func _input(event: InputEvent) -> void:
	# browsers only allow mouse capture after the user has interacted with the 
	# game, so the mouse mode has to be set in _input
	# see https://docs.godotengine.org/en/stable/getting_started/workflow/export/exporting_for_web.html#full-screen-and-mouse-capture
	if MOUSE_CAPTURE:
		if not USE_CROSSHAIR:
			if not Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			if AIMER_VISIBLE:
				if not Input.get_mouse_mode() == Input.MOUSE_MODE_CONFINED:
					Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
					Input.set_custom_mouse_cursor(load("res://UI/cross.png"))



func set_music_volume(volume: float):
	var index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(index, linear2db(volume))
	SETTINGS_MUSIC = volume
	
func set_sound_volume(volume: float):
	var index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(index, linear2db(volume))
	SETTINGS_SOUND = volume
