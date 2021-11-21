extends Node2D

onready var shroom_ui

func _ready():
	GameStatus.CURRENT_ACT = self
	GameStatus.CURRENT_YSORT = $YSort
	GameStatus.CURRENT_UI = $UI
	GameStatus.CURRENT_PLAYER = $YSort/Player
	GameStatus.CURRENT_CAMERA = $ScriptedCamera
	GameStatus.CURRENT_CAM_REMOTE = $YSort/Player/CamRemote
	GameStatus.CURRENT_HEALTH = GameStatus.PLAYER_MAX_HEALTH
	GameStatus.MOVE_ENABLED = true
	GameStatus.SPRAY_ENABLED = true
	GameStatus.AIMER_VISIBLE = true
	GameStatus.HEALTH_VISIBLE = true
	GameStatus.MOUSE_CAPTURE = true
	GameStatus.SHOOT_ENABLED = true
	GameStatus.DASH_ENABLED = true
	
	# what should definitely be activated in the Arena?	
	shroom_ui = GameStatus.CURRENT_UI.get_node("ShroomUI")
	shroom_ui._on_Growth_animation_finished()
	
	GameEvents.connect("arena_wave1", self, "arena_wave1")
	GameEvents.connect("arena_wave2", self, "wave2")


func arena_wave1():
	print("wave1")
	GameEvents.trigger_unique_event("arena_wave2")
	
func wave2():
	print("wave2")
	pass


func reset():
	pass



func _on_Wave1TriggerZone_body_entered(body: Node) -> void:
	GameEvents.trigger_unique_event("arena_wave1")
