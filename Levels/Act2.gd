extends Node2D

onready var scout = $YSort/AntScout as AntEnemy
onready var shooter1 := $YSort/AntShooter as AntEnemy
onready var shooter2 := $YSort/AntShooter2 as AntEnemy
onready var shooter3 := $YSort/AntShooter3 as AntEnemy
onready var movable_rock = $YSort/Rocks/MovableRock
onready var thrower := $YSort/Room/Enemies/Thrower as AntEnemy

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
	GameEvents.connect("room_checkpoint", self, "room_checkpoint")
	GameEvents.connect("room_cutscene", self, "room_cutscene")
	
	scout.set_facing_direction(Vector2.LEFT)
	scout.get_node("StateMachine").enabled = false
	
	$YSort/AphidPathWithAphid/RedAphid.get_node("StateMachine").start()
	
	var shooter_behavior = {
		"Chase": 0.0,
		"SimpleShoot": 1.0,
		"Sprint": 0.0
	}
	var lower_health := 8 # default is 20
	
	for shooter in [shooter1, shooter2, shooter3]:
		shooter.set_behavior(shooter_behavior)
		shooter.get_node("EnemyStats").set_max_health(lower_health)
	
	
	var thrower_behavior = {
		"Chase": 1.0,
		"SimpleShoot": 1.0,
		"ThrowAphid": 0.6,
		"Sprint": 0.0,
	}
	thrower.set_behavior(thrower_behavior)
	
	$YSort/Room/Enemies/Guard1.set_facing_direction(Vector2.RIGHT)
	$YSort/Room/Enemies/Guard2.set_facing_direction(Vector2.LEFT)
	$YSort/Room/Enemies/Talker1.set_facing_direction(Vector2.RIGHT)
	$YSort/Room/Enemies/Talker2.set_facing_direction(Vector2.LEFT)
	$YSort/Room/Enemies/Thrower.set_facing_direction(Vector2.LEFT)

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
	
	# TODO calculate beginning enemy_dead into this
	
	GameStatus.MOVE_ENABLED = true
	GameStatus.SPRAY_ENABLED = true
	GameStatus.AIMER_VISIBLE = true

func _on_ShooterTrigger_body_entered(body):
	shooter1.state_machine.enabled = true



func _on_StickClose_body_entered(body: Node) -> void:
	GameEvents.trigger_unique_event("stick_close")

var chase_right_detector := false
const DYNAMIC_CAM = preload("res://Levels/DynamicPlayerCam.tscn")
func small_chase():
	scout.global_position = $Positions/ScoutRunAway.global_position + Vector2(700.0 if chase_right_detector else 0.0, 0)
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
	pass

func _on_SmallChase_body_entered(body: Node) -> void:
	GameEvents.trigger_unique_event("small_chase")

func _on_SmallChase2_body_entered(body: Node) -> void:
	chase_right_detector = true
	GameEvents.trigger_unique_event("small_chase")

func _on_ZoneRoomCutscene_body_entered(body: Node) -> void:
	GameEvents.trigger_unique_event("room_cutscene")

var room_agitated := false
func agitate_everyone():
	for name in ["Guard1", "Guard2", "Talker1", "Talker2", "Thrower"]:
		if !has_node("YSort/Room/Enemies/" + name + "/StateMachine"):
			continue
		var state_machine = get_node("YSort/Room/Enemies/" + name + "/StateMachine")
		if not state_machine.enabled:
			state_machine.enabled = true

func _on_TopAgitator_body_entered(body: Node) -> void:
	if !room_agitated:
		room_agitated = true
		$YSort/Room/Enemies/Guard1.look_at(GameStatus.CURRENT_PLAYER.global_position)
		$YSort/Room/Enemies/Guard2.look_at(GameStatus.CURRENT_PLAYER.global_position)
		$YSort/Room/Enemies/Guard1/SpeechBubble.set_text("[shake]CORDYCEPS IS HERE![/shake]")
		yield(get_tree().create_timer(1.5), "timeout")
		$YSort/Room/Enemies/Guard1/StateMachine.enabled = true
		$YSort/Room/Enemies/Guard2/StateMachine.enabled = true
		yield(get_tree().create_timer(4), "timeout")
		agitate_everyone()
	else:
		agitate_everyone()


func _on_LeftAgitator_body_entered(body: Node) -> void:
	if !room_agitated:
		room_agitated = true
		$YSort/Room/Enemies/Talker1.look_at(GameStatus.CURRENT_PLAYER.global_position)
		$YSort/Room/Enemies/Talker2.look_at(GameStatus.CURRENT_PLAYER.global_position)
		$YSort/Room/Enemies/Talker1/SpeechBubble.set_text("[shake]CORDYCEPS IS HERE![/shake]")
		yield(get_tree().create_timer(1.5), "timeout")
		$YSort/Room/Enemies/Talker1/StateMachine.enabled = true
		$YSort/Room/Enemies/Talker2/StateMachine.enabled = true
		yield(get_tree().create_timer(4), "timeout")
		agitate_everyone()
	else:
		agitate_everyone()


func _on_RightAgitator_body_entered(body: Node) -> void:
	if !room_agitated:
		room_agitated = true
		$YSort/Room/Enemies/Thrower.look_at(GameStatus.CURRENT_PLAYER.global_position)
		$YSort/Room/Enemies/Thrower/SpeechBubble.set_text("[shake]CORDYCEPS IS HERE![/shake]")
		yield(get_tree().create_timer(1.5), "timeout")
		$YSort/Room/Enemies/Thrower/StateMachine.enabled = true
		yield(get_tree().create_timer(4), "timeout")
		agitate_everyone()
	else:
		agitate_everyone()

func ant_kicks_stone():
	var kicker := $YSort/Room/Enemies/Guard2 as AntEnemy
	var stone := $YSort/Room/KickStone as Node2D
	var tween := $YSort/Room/KickStone/Tween as Tween
	tween.interpolate_property(kicker, "global_position", kicker.global_position, stone.global_position + Vector2(20, -35), 3)
	tween.start()
	kicker.set_facing_direction(Vector2.DOWN)
	kicker.animation_state.travel("Walk")
	yield(tween, "tween_all_completed")
	kicker.animation_state.travel("Idle")
	yield(get_tree().create_timer(.5), "timeout")
	kicker.animation_state.travel("Throw")
	tween.interpolate_property(stone, "global_position", stone.global_position, stone.global_position + Vector2(0, 150), 1.5, Tween.TRANS_QUINT, Tween.EASE_OUT)
	tween.start()

func room_cutscene():
	scout.state_machine.get_node("FollowPath").FOLLOW_ACCELERATION -= 20000
	scout.global_position = $Positions/ScoutAwayFromStick.global_position
	GameStatus.MOVE_ENABLED = false
	GameStatus.SPRAY_ENABLED = false
	GameStatus.DASH_ENABLED = false
	for i in range(4):
		get_node("YSort/Room/Enemies/RedAphid"+str(i+1)+"/StateMachine").enabled = true
	$ScriptedCamera.follow(scout)
	var runpath := []
	for i in range(2):
		runpath.append(get_node("Positions/ScoutRoom" + str(i+1)).global_position)
	scout.follow_path_array(runpath)
	ant_kicks_stone()
	yield(scout, "follow_completed") # POINT 2 REACHED
	$YSort/Room/Enemies/Guard1.set_facing_direction(Vector2.DOWN)
	$YSort/Room/Enemies/Guard2.set_facing_direction(Vector2.DOWN)
	scout.follow_path($Positions/ScoutRoom3.global_position)
	yield(scout, "follow_completed") # POINT 3 REACHED
	thrower.set_facing_direction(Vector2.DOWN)
	scout.follow_path($Positions/ScoutRoom4.global_position)
	yield(scout, "follow_completed") # POINT 4 REACHED
	scout.set_facing_direction(Vector2.UP)
	scout.get_node("SpeechBubble").set_text("We have an emergency!", 1.0)
	yield(scout.get_node("SpeechBubble"), "dialog_completed")
	scout.get_node("SpeechBubble").set_text("A [shake]raging cordyceps[/shake] is headed our way", 1.0)
	yield(scout.get_node("SpeechBubble"), "dialog_completed")
	thrower.get_node("SpeechBubble").set_text("Oh nyo", 1.0)
	yield(thrower.get_node("SpeechBubble"), "dialog_completed")
	scout.get_node("SpeechBubble").set_text("It already [color=#ff0000][shake]killed[/shake][/color] some of us", 1.0)
	yield(scout.get_node("SpeechBubble"), "dialog_completed")
	thrower.get_node("SpeechBubble").set_text("Ok, notify the others", 1.0)
	yield(thrower.get_node("SpeechBubble"), "dialog_completed")
	thrower.get_node("SpeechBubble").set_text("We'll keep guarding this place", 1.0)
	yield(thrower.get_node("SpeechBubble"), "dialog_completed") # DIALOG OVER
	var runpath2 := []
	for i in range(5):
		runpath2.append(get_node("Positions/ScoutRoomExit" + str(i+1)).global_position)
	scout.follow_path_array(runpath2)
	$ScriptedCamera.back_to_player()
	yield($ScriptedCamera, "back_at_player")
	GameStatus.MOVE_ENABLED = true
	GameStatus.SPRAY_ENABLED = true
	GameStatus.DASH_ENABLED = true

func room_checkpoint():
	GameStatus.MOVE_ENABLED = true
	GameStatus.SPRAY_ENABLED = true
	GameStatus.DASH_ENABLED = true
	scout.queue_free()
	thrower.global_position = $Positions/ThrowerNewPosition.global_position
	thrower.set_facing_direction(Vector2.RIGHT)
	$YSort/Room/Enemies/Guard1.set_facing_direction(Vector2.UP)
	$YSort/Room/Enemies/Guard2.set_facing_direction(Vector2.UP)

func _on_TriggerArea_body_entered(body: Node) -> void:
	yield(get_tree().create_timer(0.1), "timeout")
	GameEvents.trigger_unique_event("room_checkpoint")


func _on_ShooterTrigger2_body_entered(body: Node) -> void:
	shooter2.state_machine.enabled = true
	shooter3.state_machine.enabled = true
