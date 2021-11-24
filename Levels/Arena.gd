extends Node2D

onready var cordy
onready var shot_caller = $YSort/ShotcallerAnt as AntEnemy
onready var shot_caller_speech = $YSort/ShotcallerAnt/SpeechBubble as SpeechBubble
onready var w1_ant1 = $YSort/Wave1Enemies/AntEnemy1
onready var w1_ant2 = $YSort/Wave1Enemies/AntEnemy2
onready var w1_ant3 = $YSort/Wave1Enemies/AntEnemy3
onready var w1_ant4 = $YSort/Wave1Enemies/AntEnemy4

onready var gate = $Positions/GatePass.global_position

# ants should come later once 2 phos have been killed
onready var w2_ant1 = $YSort/Wave2Enemies/AntEnemy1
onready var w2_ant2 = $YSort/Wave2Enemies/AntEnemy2
onready var w2_pho1 = $YSort/Wave2Enemies/Phoridae1
onready var w2_pho2 = $YSort/Wave2Enemies/Phoridae2
onready var w2_pho3 = $YSort/Wave2Enemies/Phoridae3


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
	
	# phos invisible till wave 2
	w2_pho1.visible = false
	w2_pho2.visible = false
	w2_pho3.visible = false
	w2_pho1.very_aggressive = true
	w2_pho2.very_aggressive = true
	w2_pho3.very_aggressive = true
	
	var player_died_baseline = GameEvents.count("player_died")


	CheckpointManager.connect("player_respawned", self, "died_in_arena")
	
	# what should definitely be activated in the Arena?	
	cordy = GameStatus.CURRENT_UI.get_node("ShroomUI") as Cordy
	cordy._on_Growth_animation_finished()
	cordy.set_eyes("idle")
	
	enemies_killed_baseline = GameEvents.count('enemy_died')
	
	GameEvents.connect("arena_wave1", self, "wave1")
	GameEvents.connect("arena_wave2", self, "wave2")
	GameEvents.connect("shroom_to_shroom_talk", self, "shroom_to_shroom_talk")


func last_enemy_ready_wave1():
	w1_ant1.trigger()
	w1_ant2.trigger()
	w1_ant3.trigger()
	w1_ant4.trigger()
	
func last_enemy_ready_wave2():
	# TODO more enemies
	w2_ant1.trigger()
	w2_ant2.trigger()
	w2_pho1.trigger()
	w2_pho2.trigger()

func wave1():
	GameStatus.MOVE_ENABLED = false
	GameStatus.SHOOT_ENABLED = false
	GameStatus.DASH_ENABLED = false
	GameStatus.SPRAY_ENABLED = false
	GameStatus.AIMER_VISIBLE = false
	
	$ScriptedCamera.follow(shot_caller, 1.8)
	yield($ScriptedCamera, "follow_target_reached")
	shot_caller_speech.set_text("Welcome to the arena!", 1.5)
	yield(shot_caller_speech, "dialog_completed")
	shot_caller_speech.set_text("We've been expecting you, scoundrel.", 1.5)
	yield(shot_caller_speech, "dialog_completed")
	shot_caller_speech.set_text("There is an extraordinary cast of brave soldiers waiting..", 0.6) 
	yield(shot_caller_speech, "dialog_completed")
	cordy.set_eyes("bored")
	cordy.say("Yes! What a perfect occasion to try out your newfound abilities.")
	shot_caller_speech.set_text("..who will ensure your inevitable downfall!", 0.9)
	yield(shot_caller_speech, "dialog_completed")

	shot_caller_speech.set_text("Enter the Arena, fellow ants!", 0.6)	
	yield(shot_caller_speech, "dialog_completed")
	$ScriptedCamera.stop_following()
	$ScriptedCamera.slide_away_to($Positions/GatePass.global_position, 1.8)
	yield($ScriptedCamera, "slide_finished")
	cordy.set_eyes("happy")	

	w1_ant3.connect("follow_completed", self, "last_enemy_ready_wave1")
	w1_ant1.follow_path_array([gate, $Positions/Wave11.global_position])
	w1_ant2.follow_path_array([gate, $Positions/Wave11.global_position, $Positions/Wave12.global_position])
	w1_ant3.follow_path_array([gate, $Positions/Wave14.global_position, $Positions/Wave13.global_position])
	w1_ant4.follow_path_array([gate, $Positions/Wave14.global_position])
#	last_enemy_ready_wave1()  # DELETE THIS
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
	w2_pho1.visible = true
	w2_pho2.visible = true
	w2_pho3.visible = true
	yield(get_tree().create_timer(0.6), "timeout")
	GameStatus.MOVE_ENABLED = false
	GameStatus.SPRAY_ENABLED = false
	GameStatus.SHOOT_ENABLED = false
	GameStatus.DASH_ENABLED = false
	GameStatus.AIMER_VISIBLE = false
	$ScriptedCamera.slide_to_object(shot_caller, 1.8)
	yield($ScriptedCamera, "slide_finished")
	shot_caller_speech.set_text("Well.. let's consider that warm-up done..", 1.0)
	yield(shot_caller_speech, "dialog_completed")
	cordy.say("Pfft")
	cordy.set_eyes("bored")
	shot_caller_speech.set_text("Time to bring on the real deal, the mighty fine Phoridae!", 1.5)
	yield(shot_caller_speech, "dialog_completed")
	shot_caller_speech.set_text("No mere worker could dodge their magic shots.", 1.5)
	yield(shot_caller_speech, "dialog_completed")
	cordy.set_eyes("idle")
	cordy.say("Ignore him,rules for workers don't apply to you anymore.")
	
	# camera again to gate
	$ScriptedCamera.slide_away_to($Positions/GatePass.global_position, 1.8)
	yield($ScriptedCamera, "slide_finished")
	
	# have the wave2 enemies walk in
	w2_pho1.follow_path_array_then_fight([$Positions/Wave11.global_position])
	w2_pho2.follow_path_array_then_fight([$Positions/Wave11.global_position])
	w2_pho3.follow_path_array_then_fight([$Positions/Wave11.global_position])
	
	w2_ant1.follow_path_array_then_fight([gate, $Positions/Wave11.global_position])
	yield(get_tree().create_timer(3.4), "timeout")

	$ScriptedCamera.back_to_player(1.0)
	yield($ScriptedCamera, "slide_finished")

	GameStatus.MOVE_ENABLED = true
	GameStatus.SPRAY_ENABLED = true
	GameStatus.SHOOT_ENABLED = true
	GameStatus.DASH_ENABLED = true
	GameStatus.AIMER_VISIBLE = true
	
	# wait for wave 2 to have died
	GameEvents.connect_to_event_count('enemy_died', GameEvents.count("enemy_died") + 4, self, "after_wave2")


func after_wave2():
	print("after wave 2")
	

func reset():
	pass


func shroom_to_shroom_talk(speech_position: Vector2):
	$OtherShroomSpeech.global_position = speech_position
	cordy.say("Yo Fred, haven't seen you up here in so long!")
	yield(cordy, "speech_done")
	$OtherShroomSpeech.set_text("Uh-huh..", 0.6)
	yield($OtherShroomSpeech, "dialog_completed")
	cordy.set_eyes("happy")
	cordy.say("What have you been up to?")
	yield(cordy, "speech_done")
	$OtherShroomSpeech.set_text("You know, expanding my mycelium..", 0.8)
	yield($OtherShroomSpeech, "dialog_completed")
	$OtherShroomSpeech.set_text("Sharing some spores..", 0.6)
	cordy.set_eyes("bored")
	yield($OtherShroomSpeech, "dialog_completed")
	$OtherShroomSpeech.set_text("Being intimate with some oak roots..", 1.2)
	yield($OtherShroomSpeech, "dialog_completed")
	cordy.set_eyes("bored")
	cordy.say("Uhmmm... alright, bye then!")
	yield(get_tree().create_timer(2.5), "timeout")
	cordy.set_eyes("idle")
	cordy.say_right("The world of fungi can be so small. And weird.")


func died_in_arena():
	# wait for player to have actually respawned
	cordy.set_eyes("angry")
	cordy.say("Weak, you must do better than this.")

	

func _on_Wave1TriggerZone_body_entered(body: Node) -> void:
	GameEvents.trigger_unique_event("arena_wave1")

func _process(delta):
	if Input.is_action_just_pressed("kill_all_enemies"):
		print("kill all")
		for child in $YSort/Wave1Enemies.get_children():
			if child is AntEnemy:
				var ant_enemy = child as AntEnemy
				if ant_enemy.state_machine.enabled:
					ant_enemy.get_node("EnemyStats").health = 0
			if child is Phoridae:
				var pho = child as Phoridae
				pho.get_node("PhoridaeStats").health = 0


func _on_ShroomDialogZone_body_entered(body: Node) -> void:
	GameEvents.trigger_unique_event_with_arg("shroom_to_shroom_talk", 
	$Positions/ShroomTalkPos1.global_position)

func _on_ShroomDialogZone2_body_entered(body: Node) -> void:
	GameEvents.trigger_unique_event_with_arg("shroom_to_shroom_talk", 
	$Positions/ShroomTalkPos2.global_position)
