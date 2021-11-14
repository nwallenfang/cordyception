extends Node2D

func _ready() -> void:
	GameStatus.CURRENT_YSORT = $YSort
	GameStatus.CURRENT_UI = $UI
	GameStatus.CURRENT_PLAYER = $YSort/Player
	GameStatus.CURRENT_CAMERA = $Camera2D
	GameStatus.CURRENT_CAM_REMOTE = $YSort/Player/CamRemote
	GameStatus.CURRENT_HEALTH = GameStatus.PLAYER_MAX_HEALTH
	GameStatus.MOUSE_CAPTURE = true
	
	# one will fight you and one will move to some location
	$YSort/AntEnemy/StateMachine.enabled = true
	$YSort/AntEnemy3.follow_path($AntTarget.global_position)
	#$Camera2D.back_to_player()
