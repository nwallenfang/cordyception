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
	pass


# TutorialSpray Area2D
func _on_Area2D_body_entered(body: Node) -> void:
	GameStatus.SPRAY_ENABLED = true



func _on_ScriptedCamera_slide_finished() -> void:
	# we're at the dandelion
	$YSort/AntEnemyClimber/SpeechBubble.set_text("Man, look at that cute aphid sitting on there..")
	$YSort/AntEnemy2/SpeechBubble.set_text("I could really go for some of his sweet, sweet nectar")
	$YSort/AntEnemyClimber/SpeechBubble.set_text("Me too, now come down you stupid SHI")
	
	# manually configure the camera to go back just in time for comedic timing

