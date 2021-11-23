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
	
	scout.set_facing_direction(Vector2.LEFT)
	scout.get_node("StateMachine").enabled = false
	
	var shooter_behavior = {
		"Chase": 0.0,
		"SimpleShoot": 1.0,
		"Shoot": 0.0,
		"Sprint": 0.0
	}
	var lower_health := 8 # default is 20
	
	shooter.set_behavior(shooter_behavior)

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
	yield(scout, "follow_completed")
	scout.queue_free()
	$ScriptedCamera.back_to_player(1.0)
	GameStatus.MOVE_ENABLED = true
	GameStatus.SPRAY_ENABLED = true
	GameStatus.AIMER_VISIBLE = true


func _on_ShooterTrigger_body_entered(body):
	shooter.state_machine.enabled = true
