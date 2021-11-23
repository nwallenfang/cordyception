extends Node2D

onready var cordy
onready var shot_caller = $YSort/ShotcallerAnt as AntEnemy
onready var shot_caller_speech = $YSort/ShotcallerAnt/SpeechBubble as SpeechBubble
onready var w1_ant1 = $YSort/Wave1Enemies/AntEnemy1
onready var w1_ant2 = $YSort/Wave1Enemies/AntEnemy2
onready var w1_ant3 = $YSort/Wave1Enemies/AntEnemy3
onready var w1_ant4 = $YSort/Wave1Enemies/AntEnemy4


var enemies_killed_baseline: int

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
	GameStatus.MOUSE_CAPTURE = true
	GameStatus.SHOOT_ENABLED = true
	GameStatus.DASH_ENABLED = true
	
	# what should definitely be activated in the Arena?	
	cordy = GameStatus.CURRENT_UI.get_node("ShroomUI") as Cordy
	cordy._on_Growth_animation_finished()
	
	enemies_killed_baseline = GameEvents.count('enemy_died')
	
	GameEvents.connect("arena_wave1", self, "wave1")
	GameEvents.connect("arena_wave2", self, "wave2")


func last_enemy_ready():
	print("trigger")
	w1_ant1.trigger()
	w1_ant2.trigger()
	w1_ant3.trigger()
	w1_ant4.trigger()



func wave1():
	GameStatus.MOVE_ENABLED = false
	GameStatus.SHOOT_ENABLED = false
	GameStatus.DASH_ENABLED = false
	GameStatus.SPRAY_ENABLED = false
	GameStatus.AIMER_VISIBLE = false
	
#	$ScriptedCamera.follow(shot_caller, 1.8)
#	yield($ScriptedCamera, "follow_target_reached")
#	shot_caller_speech.set_text("Welcome to the arena!", 1.5)
#	yield(shot_caller_speech, "dialog_completed")
#	shot_caller_speech.set_text("We've been expecting you, scoundrel.", 1.5)
#	yield(shot_caller_speech, "dialog_completed")
#	shot_caller_speech.set_text("There is an extraordinary cast of brave soldiers waiting..", 0.6) 
#	yield(shot_caller_speech, "dialog_completed")
#	cordy.set_eyes("bored")
#	cordy.say("Pfft..")
#	shot_caller_speech.set_text("..who will ensure your inevitable downfall!", 0.9)
#	yield(shot_caller_speech, "dialog_completed")
#
#	shot_caller_speech.set_text("Enter the Arena, fellow ants!", 0.6)	
#	yield(shot_caller_speech, "dialog_completed")
#	$ScriptedCamera.stop_following()
	$ScriptedCamera.slide_away_to($Positions/GatePass.global_position, 1.8)
	yield($ScriptedCamera, "slide_finished")
	cordy.set_eyes("happy")	
	var gate = $Positions/GatePass.global_position
	w1_ant3.connect("follow_completed", self, "last_enemy_ready")
	w1_ant1.follow_path_array([gate, $Positions/Wave11.global_position])
	w1_ant2.follow_path_array([gate, $Positions/Wave11.global_position, $Positions/Wave12.global_position])
	w1_ant3.follow_path_array([gate, $Positions/Wave14.global_position, $Positions/Wave13.global_position])
	w1_ant4.follow_path_array([gate, $Positions/Wave14.global_position])
	
	yield(get_tree().create_timer(3.8), "timeout")
	$ScriptedCamera.back_to_player(1.0)
	
	GameStatus.MOVE_ENABLED = true
	GameStatus.SPRAY_ENABLED = true
	GameStatus.SHOOT_ENABLED = true
	GameStatus.DASH_ENABLED = true
	GameStatus.AIMER_VISIBLE = true
	GameEvents.connect_to_event_count('enemy_died', enemies_killed_baseline + 4, self, "wave2")
	# fight fight fight
	

	
func wave2():
	GameEvents.trigger_unique_event("arena_wave2")
	shot_caller_speech.set_text("Welcome to the arena!", 1.5)
	yield(shot_caller_speech, "dialog_completed")



func reset():
	pass



func _on_Wave1TriggerZone_body_entered(body: Node) -> void:
	GameEvents.trigger_unique_event("arena_wave1")

func _process(delta):
	if Input.is_action_just_pressed("kill_all_enemies"):
		print("kill all")
		for child in $YSort/Wave1Enemies.get_children():
			if child is AntEnemy:
				var ant_enemy = child as AntEnemy
				if ant_enemy.state_machine.enabled:
					ant_enemy.call_deferred("queue_free")
