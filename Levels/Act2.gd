extends Node2D

onready var scout = $YSort/AntScout
onready var movable_rock = $YSort/Rocks/MovableRock

func _ready():
	GameStatus.CURRENT_ACT = self
	GameStatus.CURRENT_YSORT = $YSort
	GameStatus.CURRENT_UI = $UI
	GameStatus.CURRENT_PLAYER = $YSort/Player
	GameStatus.CURRENT_CAMERA = $ScriptedCamera
	GameStatus.CURRENT_CAM_REMOTE = $YSort/Player/CamRemote
	GameStatus.CURRENT_HEALTH = GameStatus.PLAYER_MAX_HEALTH
	GameStatus.MOUSE_CAPTURE = true
	
	GameEvents.connect("scout_dialog", self, "scout_dialog")
	
	scout.set_facing_direction(Vector2.LEFT)
	scout.get_node("StateMachine").enabled = false


func on_dash_tutorial_entered(body: Node):
	GameStatus.DASH_ENABLED = true


func reset():
	pass


func _on_ZoneScout_body_entered(body: Node) -> void:
	# have the scout say something then turn and leave
	# later have it visible change the path towards thorns
	GameEvents.trigger_unique_event("scout_dialog")

func scout_dialog():
	scout.get_node("SpeechBubble").set_text("Oh, no. Cordyceps danger!")
	# camera should follow scout for a short time
	$ScriptedCamera.follow(scout, 0.6)
	# scout should put rock obstacle
	scout.follow_path($Positions/Scout1.global_position)
	yield(scout, "follow_completed")
	scout.follow_path($Positions/Scout2.global_position)
	yield(scout, "follow_completed")
	$Positions/PositionTween.reset_all()
	$Positions/PositionTween.interpolate_property(movable_rock, "global_position", movable_rock.global_position, $Positions/RockTarget.global_position, 1.2)
	$Positions/PositionTween.start()
	yield($Positions/PositionTween, "tween_all_completed")
