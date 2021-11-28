extends Node2D

onready var player = $YSort/Player as Player
onready var boss = $YSort/StagBeetle as StagBeetle
onready var boss_speech = $YSort/StagBeetle/SpeechBubble as SpeechBubble
onready var camera = $ScriptedCamera as ScriptedCamera
onready var cordy: Cordy

func _ready():
	# TODO Checkpoint
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
	GameStatus.MOUSE_CAPTURE = true
	
	boss.state_machine.enabled = false
	
	cordy = GameStatus.CURRENT_UI.get_node("ShroomUI") as Cordy
	cordy.show()
	cordy.set_eyes("idle")

	
	GameStatus.CURRENT_UI.boss_healthbar.set_max(boss.MAX_HEALTH)
	GameEvents.connect("begin_boss", self, "begin_boss_fight")
	

func begin_boss_fight():
	cordy.say("I sense a great presence")
	yield(cordy, "speech_done")
	# TODO start dramatic music
	camera.slide_to_object(boss)
	yield(camera, "slide_finished")
	boss_speech.set_text("[color=#ff0000]ARGGHH[shake]HH!!![/shake][/color]")
	yield(boss_speech, "dialog_completed")
	camera.back_to_player(0.5)
	yield(camera, "slide_finished")
	boss.get_node("StateMachine").start()
	# TODO health fade in
	GameStatus.BOSS_HEALTH_VISIBLE = true
	GameEvents.trigger_unique_event("begin_boss_cutscene_ended")


func _on_DynamicCameraZone_body_entered(body: Node) -> void:
	if GameEvents.count("begin_boss_cutscene_ended") > 0:
		$DynamicPlayerCam.target = boss
		$ScriptedCamera.follow($DynamicPlayerCam)


func _on_DynamicCameraZone_body_exited(body: Node) -> void:
	$ScriptedCamera.back_to_player()


func _on_BeginBossZone_body_entered(body: Node) -> void:
	if body as Player != null:
		GameEvents.trigger_unique_event("begin_boss")
