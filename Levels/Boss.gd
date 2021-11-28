extends Node2D

onready var player = $YSort/Player as Player
onready var boss = $YSort/StagBeetle as StagBeetle
onready var cordy: Cordy

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
	GameStatus.SHOOT_ENABLED = true
	GameStatus.DASH_ENABLED = true
	GameStatus.AIMER_VISIBLE = true
	GameStatus.HEALTH_VISIBLE = true
	GameStatus.BOSS_HEALTH_VISIBLE = true
	GameStatus.MOUSE_CAPTURE = true
	
	cordy = GameStatus.CURRENT_UI.get_node("ShroomUI") as Cordy
	cordy.show()
	cordy.set_eyes("idle")
	boss.get_node("StateMachine").start()
	
	# TODO dynamic camera!!
	
	
	GameStatus.CURRENT_UI.boss_healthbar.set_max(boss.MAX_HEALTH)
	
