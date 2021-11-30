extends AbstractState


export var MELEE_RANGE := 650.0
export var SWIPE_PROJECTILE_RANGE := 2000
export var SWIPE_PROJECTILE_SPEED := 550
# question is: where will the check be whether melee attack makes sense?
# have it be in this script for now

var swipe_old_pos: Vector2

func process(delta, first_time_entering):
	parent = parent as StagBeetle
	if first_time_entering:
		var distance_to_player = GameStatus.CURRENT_PLAYER.global_position.distance_to(parent.global_position)

		if distance_to_player > MELEE_RANGE:
			back_to_idle()
			return
		# timing is important for the hitboxes
		parent.play_animation("melee_swipe_turn")
		
		yield(get_tree().create_timer(1.2), "timeout")
		
		# Start Swipe Sprite movement
#		var start = parent.get_node("Origin/SwipeOrigin").global_position
#		var direction = parent.get_node("Origin").global_position.direction_to(start)
#		var target = SWIPE_PROJECTILE_RANGE * direction


		parent.swipe_projectile.get_node("Animation").play("fly")
#		parent.swipe_projectile.rotation_degrees = direction.angle()
#		parent.swipe_projectile.modulate = Color(1.4, 1.4, 1.4)
#		$Tween.interpolate_property(parent.swipe_projectile, "global_position", start, target, SWIPE_PROJECTILE_RANGE/SWIPE_PROJECTILE_SPEED)
#		$Tween.start()
		
#		parent.swipe_hitbox.set_deferred("monitoring", true) 
#		parent.swipe_hitbox.set_deferred("monitorable", true) 
#		parent.swipe_hitbox.set_deferred("visible", true)
#		parent.swipe_projectile.set_deferred("visible", true)

		yield(parent.sprite, "animation_finished")
#		parent.swipe_hitbox.set_deferred("monitoring", false) 
#		parent.swipe_hitbox.set_deferred("monitorable", false) 
#		parent.swipe_hitbox.set_deferred("visible", false) 
#		parent.swipe_projectile.set_deferred("visible", false)
		back_to_idle()
