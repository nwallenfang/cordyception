extends Node2D

onready var climber = $YSort/DandelionRoom/AntEnemyClimber
onready var climber_speech = $YSort/DandelionRoom/AntEnemyClimber/SpeechBubble
onready var ant1 = $YSort/DandelionRoom/AntEnemy1
onready var ant1_speech = $YSort/DandelionRoom/AntEnemy1/SpeechBubble
onready var ant2 = $YSort/DandelionRoom/AntEnemy2
onready var ant2_speech = $YSort/DandelionRoom/AntEnemy2/SpeechBubble
onready var player = $YSort/Player

func _ready() -> void:
	GameStatus.CURRENT_YSORT = $YSort
	GameStatus.CURRENT_UI = $UI
	GameStatus.CURRENT_PLAYER = $YSort/Player
	GameStatus.CURRENT_CAMERA = $ScriptedCamera
	GameStatus.CURRENT_CAM_REMOTE = $YSort/Player/CamRemote
	GameStatus.CURRENT_HEALTH = GameStatus.PLAYER_MAX_HEALTH
	GameStatus.MOUSE_CAPTURE = true
	GameStatus.HEALTH_VISIBLE = false
	
#	$YSort/AntEnemy4.set_facing_direction(Vector2.LEFT)
	GameEvents.connect("dandelion_dialog", self, "dandelion_dialog")
	GameEvents.connect("dandelion_attack", self, "dandelion_attack")
	
	# give the 3 ants simpler behavior and less HP
	var simpler_behavior = {
		"Chase": 1.0,
		"SimpleShoot": 1.0,
		"Shoot": 0.0,
		"Sprint": 0.0
	}
	var lower_health := 20  # default is 20
	
	ant1.set_behavior(simpler_behavior)
	ant2.set_behavior(simpler_behavior)
	climber.set_behavior(simpler_behavior)
	
	# set lower max health
	ant1.get_node("EnemyStats").set_max_health(lower_health)
	ant2.get_node("EnemyStats").set_max_health(lower_health)
	climber.get_node("EnemyStats").set_max_health(lower_health)
	
func dandelion_dialog():
	GameStatus.MOVE_ENABLED = false
	$ScriptedCamera.slide_to_object($YSort/DandelionRoom/SpecialDandelion)
	yield($ScriptedCamera, "slide_finished")
	climber.get_node("SpeechBubble").set_text("Man, look at that cute aphid sitting on there..", 1.0)
	yield(climber.get_node("SpeechBubble"), "dialog_completed")
	ant1.get_node("SpeechBubble").set_text("I could really go for some of its sweet, sweet nectar", 0.8)
	yield(ant1.get_node("SpeechBubble"), "dialog_completed")
	ant1.get_node("SpeechBubble").set_text("Now come down you stupid SHI")
	var comedic_timer = get_tree().create_timer(1.3)
	yield(comedic_timer, "timeout")
	# manually configure the camera to go back just in time for comedic timing
	$ScriptedCamera.back_to_player(1.2)
	GameStatus.MOVE_ENABLED = true


func look_towards_player():
	var direction1 = (player.global_position - ant1.global_position).normalized()
	var direction2 = (player.global_position - ant2.global_position).normalized()
	var direction_climb = (player.global_position - climber.global_position).normalized()
	ant1.animation_tree.set("parameters/Idle/blend_position", direction1)
	climber.animation_tree.set("parameters/Idle/blend_position", direction_climb)
	ant2.animation_tree.set("parameters/Idle/blend_position", direction2)

func dandelion_attack():
	# disable controls
	GameStatus.MOVE_ENABLED = false
	GameStatus.SPRAY_ENABLED = false
	GameStatus.AIMER_VISIBLE = false
	# climber ant on stängel
	pass
	# center camera (no margins)
	$ScriptedCamera.slide_to_object($YSort/DandelionRoom/SpecialDandelion, 1.5)
	yield($ScriptedCamera, "slide_finished")
	# teleport player to start position
	player.global_position = $Positions/PlayerStart.global_position
	# move player to target position
	player.follow_path($Positions/PlayerTargetPos.global_position)
	yield(player, "follow_completed")
	
	# rotate enemies towards player
	look_towards_player()


	# dialog
	ant1_speech.set_text("Hey, looks like you could lend us a hand.")
	yield(get_tree().create_timer(1.4), "timeout")
	ant1_speech.stop_and_blend()
	ant2_speech.set_text("DON'T TALK TO THAT FREAK. SHE'S INFESTED!")
	yield(ant2_speech, "dialog_completed")
	# interruption?
	climber_speech.set_text("Disgusting.")
	
	# climber ant reset
	pass 
	
	# shoot single projectile towards player
	ant1.shoot_single_projectile(player.global_position)
	# wait until projectile has hit the player
	yield(player.get_node("Hurtbox"), "area_entered")
	
	# camera flash
	pass
	
	# enable controls
	GameStatus.HEALTH_VISIBLE = true
	GameStatus.MOVE_ENABLED = true
	GameStatus.SPRAY_ENABLED = true
	GameStatus.AIMER_VISIBLE = true
	$ScriptedCamera.back_to_player(0.5)
	# trigger enemies
	ant1.trigger()
	ant2.trigger()
	climber.trigger()

# TutorialSpray Area2D
func _on_Area2D_body_entered(body: Node) -> void:
	GameStatus.SPRAY_ENABLED = true


func _on_Zone_body_entered(body: Node) -> void:
	GameEvents.trigger_unique_event("dandelion_dialog")


func _on_Zone2_body_entered(body: Node) -> void:
	GameEvents.trigger_unique_event("dandelion_attack")
