extends RayCast2D
class_name ScentRay

func get_player_scent_position() -> Vector2:
	var player := GameStatus.CURRENT_PLAYER

	cast_to = player.position - get_parent().position
	force_raycast_update()
	
	if !is_colliding():
		return player.position
	else:
		for scent in player.scent_spawner.scent_trail:
			cast_to = scent.position - get_parent().position
			force_raycast_update()

			if !is_colliding():
				return scent.position
	
	return get_parent().position
	
	
func get_player_scent_position_global() -> Vector2:
	var player := GameStatus.CURRENT_PLAYER

	cast_to = player.position - get_parent().position
	force_raycast_update()
	
	if !is_colliding():
		return player.global_position
	else:
		for scent in player.scent_spawner.scent_trail:
			cast_to = scent.position - get_parent().position
			force_raycast_update()

			if !is_colliding():
				return scent.global_position
	
	return get_parent().global_position
