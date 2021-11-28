extends AbstractState


var direction: float # will be set from process
func shoot_projectiles():
	# wait for shoot delay
	$EnemyProjectileSpawner.global_position = parent.projectile_origin.global_position
	$EnemyProjectileSpawner.spawn_cone_projectile_volley(direction, 40, 6, 0.3, 3)


func process(delta: float, first_time_entering: bool) -> void:
	var direction_to_player = parent.global_position.direction_to(GameStatus.CURRENT_PLAYER.global_position)
	direction = direction_to_player.angle() + PI/2
	
	var direction_to_player_helper = GameStatus.CURRENT_PLAYER.global_position.direction_to(parent.global_position)
	var angle_deg = parent.normalize_angle(rad2deg(direction_to_player_helper.angle()) + 90 - parent.sprite_rotation)

	if angle_deg > 45 or angle_deg < -45:
		# makes no sense to shoot here
		state_machine.transition_deferred("Idle")
	elif first_time_entering:
		parent.play_animation("shoot_once")
		yield(get_tree().create_timer(0.5), "timeout")
		shoot_projectiles()
		yield(get_tree().create_timer(2.5), "timeout")
		state_machine.transition_deferred("Idle")
