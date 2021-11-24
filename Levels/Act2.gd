extends Node2D

onready var scout = $YSort/AntScout as AntEnemy
onready var shooter := $YSort/AntShooter as AntEnemy
onready var movable_rock = $YSort/Rocks/MovableRock

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
	
	GameEvents.connect("scout_dialog", self, "scout_dialog")
	GameEvents.connect("small_chase", self, "small_chase")
	
	scout.set_facing_direction(Vector2.LEFT)
	scout.get_node("StateMachine").enabled = false
	
	$YSort/AphidPathWithAphid/RedAphid.get_node("StateMachine").start()
	
	var shooter_behavior = {
		"Chase": 0.0,
		"SimpleShoot": 1.0,
		"Shoot": 0.0,
		"Sprint": 0.0
	}
	var lower_health := 8 # default is 20
	
	shooter.set_behavior(shooter_behavior)
	shooter.get_node("EnemyStats").set_max_health(lower_health)

func on_dash_tutorial_entered(body: Node):
	GameStatus.DASH_ENABLED = true

func reset():
	pass


func _on_ZoneScout_body_entered(body: Node) -> void:
	# have the scout say something then turn and leave
	# later have it visible change the path towards thorns
	GameEvents.trigger_unique_event("scout_dialog")

func scout_dialog():
	GameStatus.MOVE_ENABLED = false
	GameStatus.SPRAY_ENABLED = false
	GameStatus.AIMER_VISIBLE = false
	scout.get_node("SpeechBubble").set_text("Oh, no. Cordyceps danger!", 1.5)
	# camera should follow scout for a short time
	$ScriptedCamera.follow(scout, 0.6)
	# scout should put rock obstacle
	scout.follow_path($Positions/Scout1.global_position)
	yield(scout, "follow_completed")
	scout.follow_path($Positions/Scout2.global_position)
	yield(scout, "follow_completed")
	$Positions/PositionTween.reset_all()
	$Positions/PositionTween.interpolate_property(movable_rock, "global_position", movable_rock.global_position, $Positions/RockTarget.global_position, 0.36)
	$Positions/PositionTween.start()
	scout.get_node("SpeechBubble").set_text("Hehehe", 0.6)
	yield($Positions/PositionTween, "tween_all_completed")
	$YSort/StoneDust.visible = true
	$YSort/StoneDust/AnimatedSprite.frame = 0
	$YSort/StoneDust/AnimatedSprite.connect("animation_finished", $YSort/StoneDust, "queue_free")
	$YSort/StoneDust2.visible = true
	$YSort/StoneDust2/AnimatedSprite.frame = 0
	$YSort/StoneDust2/AnimatedSprite.connect("animation_finished", $YSort/StoneDust2, "queue_free")
	$ScriptedCamera.stop_following()
	scout.follow_path($Positions/ScoutRunAway.global_position)
	yield(get_tree().create_timer(1.0), "timeout")
	$ScriptedCamera.back_to_player(1.0)
	yield($ScriptedCamera, "back_at_player")
	GameStatus.MOVE_ENABLED = true
	GameStatus.SPRAY_ENABLED = true
	GameStatus.AIMER_VISIBLE = true

func _on_ShooterTrigger_body_entered(body):
	shooter.state_machine.enabled = true

func _on_SmallChase_body_entered(body: Node) -> void:
	scout.global_position = $Positions/ScoutRunAway.global_position
	GameEvents.trigger_unique_event("small_chase")

func _on_StickClose_body_entered(body: Node) -> void:
	GameEvents.trigger_unique_event("stick_close")

const DYNAMIC_CAM = preload("res://Levels/DynamicPlayerCam.tscn")
func small_chase():
	var dyn_cam = DYNAMIC_CAM.instance()
	GameStatus.CURRENT_YSORT.add_child(dyn_cam)
	dyn_cam.target = scout
	$ScriptedCamera.follow(dyn_cam)
	scout.state_machine.get_node("FollowPath").FOLLOW_ACCELERATION += 50000
	var runpath := []
	for i in range(5):
		runpath.append(get_node("Positions/ScoutStick" + str(i+1)).global_position)
	scout.follow_path_array(runpath)
	yield(get_tree().create_timer(1.8), "timeout")
	scout.state_machine.execute_state_once("SimpleShoot")
	yield(get_tree().create_timer(1.5), "timeout")
	scout.get_node("SpeechBubble").set_text("REEEEE", 0.6)
	#scout.shoot_single_projectile(GameStatus.CURRENT_PLAYER.global_position)
	
	yield(scout.get_node("SpeechBubble"), "dialog_completed")
	#scout.shoot_single_projectile(GameStatus.CURRENT_PLAYER.global_position)
	scout.state_machine.execute_state_once("Shoot")
	scout.get_node("SpeechBubble").set_text("Get away from me!", 1.0)
	yield(scout, "follow_completed")
	scout.get_node("StateMachine").stop()
	$ScriptedCamera.back_to_player()
	$Detector/StickClose.monitorable = true
	$Detector/StickClose.monitoring = true
	yield(GameEvents, "stick_close")
	stick_close()
	

func stick_close():
	$YSort/MoveStick/Tween.interpolate_property($YSort/MoveStick, "rotation", 0, deg2rad(25.0), 0.5)
	$YSort/MoveStick/Tween.start()
	scout.follow_path($Positions/ScoutStickPush.global_position)
	yield(get_tree().create_timer(0.2), "timeout")
	$YSort/StickDust.visible = true
	$YSort/StickDust/AnimatedSprite.frame = 0
	$YSort/StickDust/AnimatedSprite.connect("animation_finished", $YSort/StickDust, "queue_free")
	$YSort/StickDust2.visible = true
	$YSort/StickDust2/AnimatedSprite.frame = 0
	$YSort/StickDust2/AnimatedSprite.connect("animation_finished", $YSort/StickDust2, "queue_free")
	yield(get_tree().create_timer(.5), "timeout")
	scout.get_node("SpeechBubble").set_text("Spread your spores somewhere else!", 1.6)
	yield(get_tree().create_timer(1.3), "timeout")
	scout.state_machine.execute_state_once("ThrowAphid")
	yield(scout.state_machine, "state_once_executed")
	yield(get_tree().create_timer(.2), "timeout")
	scout.follow_path($Positions/ScoutAwayFromStick.global_position)


func _on_TriggerAreaCP22_body_entered(body: Node) -> void:
	scout.global_position = $Positions/ScoutRunAway.global_position


func _on_SmallChase2_body_entered(body: Node) -> void:
	scout.global_position = $Positions/ScoutRunAway.global_position + Vector2(700.0, 0)
	GameEvents.trigger_unique_event("small_chase")
