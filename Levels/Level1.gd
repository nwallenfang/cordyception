extends Node2D

func _ready() -> void:
	GameStatus.CURRENT_YSORT = $YSort
	GameStatus.CURRENT_UI = $UI
	GameStatus.CURRENT_PLAYER = $YSort/Player
	GameStatus.CURRENT_HEALTH = GameStatus.PLAYER_MAX_HEALTH
	GameStatus.MOUSE_CAPTURE = true
	
	$YSort/AntEnemy/StateMachine.enabled = true
	
	$YSort/AntEnemy.connect("tree_exiting", self, "enable_other_ants")


func enable_other_ants():
	$DialogPlayer.play("talk")
	$YSort/AntEnemy3/StateMachine.enabled = true
	$YSort/AntEnemy4/StateMachine.enabled = true

