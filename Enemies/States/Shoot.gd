extends AbstractState


func _ready() -> void:
	RELATIVE_TRANSITION_CHANCE = 1


export var SHOOT_DELAY := 0.2
func process(delta: float, first_time_entering: bool):
	# for now either shoot a cone in the player direction or shoot radial
	if first_time_entering:
		var line2d = parent.get_node("Line2D")
		var direction = line2d.points[1].angle() + PI/2
		var random_flip := randi() % 2
		
		if parent.animation_tree != null:
			parent.animation_tree.set("parameters/Shoot/blend_position", Vector2.UP.rotated(direction))

		if random_flip:
			$EnemyProjectileSpawner.spawn_cone_projectile_volley(direction, 30, 5, 0.2, 3)
		else:
			$EnemyProjectileSpawner.spawn_radial_projectiles(16)
			
		$ShootDelayTimer.start()
		# go to shoot animation
		if parent.animation_state != null:
			parent.animation_state.travel("Shoot")
	else:
		# wait for shoot delay
		yield($ShootDelayTimer, "timeout")
		# go back to being idle in the next frame
		state_machine.transition_to("Idle")
		
	# shooting stuff could be depending on distance to player..
	# if too far from the player, don't shoot at all but enter another state instead


