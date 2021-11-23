extends Node2D

func _ready() -> void:
	GameStatus.CURRENT_YSORT = $YSort
	GameStatus.CURRENT_UI = $UI
	GameStatus.CURRENT_PLAYER = $YSort/Player
	GameStatus.CURRENT_CAMERA = $Camera2D
	GameStatus.CURRENT_CAM_REMOTE = $YSort/Player/CamRemote
	GameStatus.CURRENT_HEALTH = GameStatus.PLAYER_MAX_HEALTH
	GameStatus.MOUSE_CAPTURE = true
	GameStatus.DASH_ENABLED = true
	GameStatus.SHOOT_ENABLED = true
	GameStatus.SPRAY_ENABLED = true
	GameStatus.HEALTH_VISIBLE = true
	
	# one will fight you and one will move to some location
	
	
	var thrower_behavior = {
		"Chase": 1.0,
		"SimpleShoot": 1.0,
		"ThrowAphid": 0.3,
		"Sprint": 0.0,
		"Shoot": 0.0
	}
	$YSort/AntEnemy/StateMachine.enabled = true
	$YSort/AntEnemy.set_behavior(thrower_behavior)
	
	$YSort/RedAphid/StateMachine.enabled = true
	$YSort/RedAphid2/StateMachine.enabled = true
	$YSort/RedAphid3/StateMachine.enabled = true
	$YSort/AntEnemy3.follow_path($AntTarget.global_position)
