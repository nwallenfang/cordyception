extends Node2D

func _ready() -> void:
	GameStatus.CURRENT_YSORT = $YSort
	GameStatus.CURRENT_UI = $UI
	GameStatus.CURRENT_PLAYER = $YSort/Player
	GameStatus.CURRENT_CAMERA = $ScriptedCamera
	GameStatus.CURRENT_CAM_REMOTE = $YSort/Player/CamRemote
	GameStatus.CURRENT_HEALTH = GameStatus.PLAYER_MAX_HEALTH
	GameStatus.MOUSE_CAPTURE = true
	
#	$YSort/AntEnemy4.set_facing_direction(Vector2.LEFT)
	GameEvents.connect("dandelion_dialog", self, "dandelion_dialog")

	
func dandelion_dialog():
	GameStatus.MOVE_ENABLED = false
	$ScriptedCamera.slide_to_object($YSort/SpecialDandelion)
	yield($ScriptedCamera, "slide_finished")
	$YSort/AntEnemyClimber/SpeechBubble.set_text("Man, look at that cute aphid sitting on there..", 1.0)
	yield($YSort/AntEnemyClimber/SpeechBubble, "dialog_completed")
	$YSort/AntEnemy2/SpeechBubble.set_text("I could really go for some of its sweet, sweet nectar", 0.8)
	yield($YSort/AntEnemy2/SpeechBubble, "dialog_completed")
	$YSort/AntEnemyClimber/SpeechBubble.set_text("Me too!", 0.5) 
	yield($YSort/AntEnemy2/SpeechBubble, "dialog_completed")
	$YSort/AntEnemyClimber/SpeechBubble.set_text("Now come down you stupid SHI")
	var comedic_timer = get_tree().create_timer(1.3)
	yield(comedic_timer, "timeout")
	# manually configure the camera to go back just in time for comedic timing
	$ScriptedCamera.back_to_player(1.2)
	GameStatus.MOVE_ENABLED = true


# TutorialSpray Area2D
func _on_Area2D_body_entered(body: Node) -> void:
	GameStatus.SPRAY_ENABLED = true



func _on_ScriptedCamera_slide_finished(name: String) -> void:
	print(name)
	# we're at the dandelion



func _on_Zone_body_entered(body: Node) -> void:
	GameEvents.trigger_unique_event("dandelion_dialog")
