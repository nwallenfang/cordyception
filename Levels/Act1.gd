extends Node2D

onready var climber = $YSort/DandelionRoom/AntEnemyClimber
onready var climber_speech = $YSort/DandelionRoom/AntEnemyClimber/SpeechBubble
onready var ant1 = $YSort/DandelionRoom/AntEnemy1
onready var ant1_speech = $YSort/DandelionRoom/AntEnemy1/SpeechBubble
onready var ant2 = $YSort/DandelionRoom/AntEnemy2
onready var ant2_speech = $YSort/DandelionRoom/AntEnemy2/SpeechBubble
onready var player = $YSort/Player
onready var aphid_path = $YSort/DandelionRoom/AphidPath
onready var aphid = $YSort/DandelionRoom/AphidPath/Aphid as Aphid
onready var stick_obstacle = $YSort/DandelionRoom/StickObstacle
onready var antertainer1 = $YSort/ExitPath/Antertainer
onready var antertainer1_speech = $YSort/ExitPath/Antertainer/SpeechBubble
onready var antertainer2 = $YSort/ExitPath/Antertainer2
onready var antertainer2_speech = $YSort/ExitPath/Antertainer2/SpeechBubble
onready var aphid_tutorial_area = $Tutorials/TutorialAphid/Area2D

signal dandelion_enemies_dead

func _ready() -> void:
	randomize()
	GameStatus.CURRENT_ACT = self
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
	GameEvents.connect("enemy_died", self, "enemy_died")
	GameEvents.connect("joke_dialog", self, "joke_dialog")
	GameEvents.connect("joke_attack", self, "joke_attack")
	
	# give the 3 ants simpler behavior and less HP
	var simpler_behavior = {
		"Chase": 1.0,
		"PseudoChase": 0.6,
		"SimpleShoot": 3.0,
		"Sprint": 0.2
	}
	var lower_health := 8 # default is 20
	
	ant1.set_behavior(simpler_behavior)
	ant2.set_behavior(simpler_behavior)
	climber.set_behavior(simpler_behavior)
	
	# set lower max health
	ant1.get_node("EnemyStats").set_max_health(lower_health)
	ant2.get_node("EnemyStats").set_max_health(lower_health)
	climber.get_node("EnemyStats").set_max_health(lower_health)
	
	# rotate climber towards dandelion
	climber.set_facing_direction(Vector2.LEFT)
	
	# disable aphid pickup in the beginning
	aphid.monitor = false
	
#	$YSort/DandelionRoom/AntEnemy3.trigger()
	# manually instance the player node
#	var player_node = instance("Player")
#	add_child_below_node(self, $YSort)
#	player = $YSort/Player
	
	# JOKE ANTS
	
	var shooter_behavior := {
		"Chase": 0.7,
		"SimpleShoot": 2.0,
		"ShootVolley": 0.8,
		"ShootRadial": 0.4,
		"PseudoChase": 0.6
	}
	
	var close_combat_behavior := {
		"Chase": 1.5,
		"PseudoChase": 0.5,
		"Sprint": 1.0
	}
	
	antertainer1.set_behavior(shooter_behavior)
	antertainer2.set_behavior(close_combat_behavior)
	
	antertainer1.set_facing_direction(Vector2.RIGHT)
	antertainer2.set_facing_direction(Vector2.LEFT)

func reset():
	if is_instance_valid(ant1):
		ant1.reset()
	if is_instance_valid(ant2):
		ant2.reset()
	if is_instance_valid(climber):
		climber.reset()
	
func dandelion_dialog():
	GameStatus.MOVE_ENABLED = false
	$ScriptedCamera.slide_to_object($YSort/DandelionRoom/SpecialDandelion)
	yield($ScriptedCamera, "slide_finished")
	climber.get_node("SpeechBubble").set_text("Man, look at that cute aphid sitting on there..", 1.0)
	yield(climber.get_node("SpeechBubble"), "dialog_completed")
	ant1.get_node("SpeechBubble").set_text("I could really go for some of its sweet, sweet nectar", 0.8)
	yield(ant1.get_node("SpeechBubble"), "dialog_completed")
	climber.get_node("SpeechBubble").set_text("Me too... Come down you LITTLE SHIT")
	var comedic_timer = get_tree().create_timer(1.2)
	yield(comedic_timer, "timeout")
	# manually configure the camera to go back just in time for comedic timing
	$ScriptedCamera.back_to_player(1.5)
	GameStatus.MOVE_ENABLED = true


func look_towards_player():
	var direction1 = (player.global_position - ant1.global_position).normalized()
	var direction2 = (player.global_position - ant2.global_position).normalized()
	var direction_climb = (player.global_position - climber.global_position).normalized()
	ant1.animation_tree.set("parameters/Idle/blend_position", direction1)
	climber.animation_tree.set("parameters/Idle/blend_position", direction_climb)
	ant2.animation_tree.set("parameters/Idle/blend_position", direction2)

func enemy_died():
	# TODO check if you're in the first arena
	if GameEvents.EVENT_COUNTER["enemy_died"] == 3:
		emit_signal("dandelion_enemies_dead")

func aphid_climb_down():
	# change the 
	aphid.get_node("StateMachine").enabled = false
	aphid.facing_right = false
	aphid.play_walk_animation(Vector2.ZERO)
	$Positions/PositionTween.reset_all()
	$Positions/PositionTween.interpolate_property(aphid_path, "global_position", aphid_path.global_position, $Positions/AphidFloor.global_position, 1.8)
	aphid.get_node("Shadow").global_position = $Positions/AphidShadowFloor.global_position
	$Positions/PositionTween.interpolate_property(aphid.get_node("Shadow"), "position", aphid.get_node("Shadow").position, Vector2(0, 5.5), 1.8)
	$Positions/PositionTween.start()
	aphid.get_node("Area").set_deferred("monitorable", true)
	aphid.get_node("Area").set_deferred("monitoring", true)
	aphid_tutorial_area.set_deferred("monitorable", true)
	aphid_tutorial_area.set_deferred("monitoring", true)

func dandelion_attack():
	# make it impossible for the aphid tutorial to show for now
	aphid_tutorial_area.set_deferred("monitorable", false)
	aphid_tutorial_area.set_deferred("monitoring", false)
	
	# disable controls
	GameStatus.MOVE_ENABLED = false
	GameStatus.SPRAY_ENABLED = false
	GameStatus.AIMER_VISIBLE = false
	# climber ant to dandelion position and Climbing Sprite
	climber.global_position = $Positions/ClimberPosition.global_position
	climber.get_node("Climbing").visible = true
	climber.get_node("Sprite").visible = false
	
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
	yield(get_tree().create_timer(1.8), "timeout")
	ant1_speech.stop_and_blend()
	ant2_speech.set_text("DON'T TALK TO THAT FREAK. SHE'S INFESTED!", 1.2)
	yield(ant2_speech, "dialog_completed")
	# interruption?
	climber_speech.set_text("Disgusting, attack!", 0.7)
	yield(climber_speech, "dialog_completed")

	# shoot single projectile towards player
	ant1.shoot_single_projectile(player.global_position)
	# wait until projectile has hit the player
	yield(player.get_node("Hurtbox"), "area_entered")
	
	# climber ant reset
	climber.get_node("Climbing").visible = false
	climber.get_node("Sprite").visible = true
	# camera flash
	$ScriptedCamera.flash()
	$ScriptedCamera.back_to_player(0.1)
	yield($ScriptedCamera/FlashTween, "tween_all_completed")
	# enable controls
	GameStatus.HEALTH_VISIBLE = true
	GameStatus.MOVE_ENABLED = true
	GameStatus.SPRAY_ENABLED = true
	GameStatus.AIMER_VISIBLE = true

	# trigger enemies
	ant1.trigger()
	ant2.trigger()
	climber.trigger()
	
	# wait until the 3 ants are killed, in the arena level use an array of ants instead
	# I tried yielding individually on tree_exited but it SUCKS 
	# so instead go for a kill counter setup
	yield(self, "dandelion_enemies_dead")
		
	# let aphid climb down
	aphid_climb_down()
	# once the player has picked it up, open the passage
	stick_obstacle.call_deferred("queue_free")

# TutorialSpray Area2D
func _on_Area2D_body_entered(body: Node) -> void:
	GameStatus.SPRAY_ENABLED = true

func _on_Zone_body_entered(body: Node) -> void:
	GameEvents.trigger_unique_event("dandelion_dialog")

func _on_Zone2_body_entered(body: Node) -> void:
	GameEvents.trigger_unique_event("dandelion_attack")

func _on_TransitionArea_body_entered(body: Node) -> void:
	$ScriptedCamera.fade_out()
	yield($ScriptedCamera, "fade_out_finished")
	get_tree().change_scene("res://Levels/Act2.tscn")
	# todo set camera completely faded out instantly
	$ScriptedCamera.fade_in()

func _on_Zone3_body_entered(body: Node) -> void:
	GameEvents.trigger_unique_event("joke_dialog")

func _on_Zone4_body_entered(body: Node) -> void:
	GameEvents.trigger_unique_event("joke_attack")


var attack_started := false
func joke_dialog():
	antertainer2_speech.set_text("So, what's your brother ANThony doing lately?")
	yield(antertainer2_speech, "dialog_completed")
	if attack_started:
		return
	antertainer1_speech.set_text("He startet working as ANTrepreneur")
	yield(antertainer1_speech, "dialog_completed")
	if attack_started:
		return
	antertainer2_speech.set_text("Where that? Near the ANTarctica?")
	yield(antertainer2_speech, "dialog_completed")
	if attack_started:
		return
	antertainer1_speech.set_text("XD ... I did not ANTicipate that one")
	yield(antertainer1_speech, "dialog_completed")
	if attack_started:
		return
	antertainer2_speech.set_text("We're so funny. We should be ANTertainers")

func joke_attack():
	attack_started = true
	antertainer2.set_facing_direction(Vector2.RIGHT)
	antertainer1_speech.stop_and_blend()
	antertainer2_speech.stop_and_blend()
	yield(get_tree().create_timer(0.7),"timeout")
	antertainer2_speech.set_text("Hey, wanna ANTer our funny conversation?")
	yield(antertainer2_speech, "dialog_completed")
	antertainer1_speech.set_text("Shit, her body is ANTirely infested")
	yield(antertainer1_speech, "dialog_completed")
	antertainer2_speech.set_text("That darn fungus is our natural ANTagonist")
	yield(antertainer2_speech, "dialog_completed")
	antertainer1_speech.set_text("Let's ANT her suffering then!")
	yield(antertainer1_speech, "dialog_completed")
	antertainer1.state_machine.start()
	antertainer2.state_machine.start()


# checkpoint2
func _on_TriggerArea_body_entered(body: Node) -> void:
	# assert that the player is ready for combat when respawning
	# needed because that stuff is still disabled at the beginning of this act
	GameStatus.HEALTH_VISIBLE = true
	GameStatus.MOVE_ENABLED = true
	GameStatus.SPRAY_ENABLED = true
	GameStatus.AIMER_VISIBLE = true
