extends AbstractState

func _ready() -> void:
#	$EnemyProjectileSpawner.position = parent.get_node("Head").position
#	RELATIVE_TRANSITION_CHANCE = 1
	pass

var direction: float # will be set from process
func shoot_projectiles():
	# wait for shoot delay
	$EnemyProjectileSpawner.global_position = parent.get_node("Head").global_position
	$EnemyProjectileSpawner.spawn_cone_projectile_volley(direction, 30, 5, 0.2, 3)



func process(delta: float, first_time_entering: bool):
	# for now either shoot a cone in the player direction or shoot radial
	if first_time_entering:
		var line2d = parent.get_node("Line2D")
		direction = line2d.points[1].angle() + PI/2
	
		if parent.animation_tree != null:
			parent.animation_tree.set("parameters/Shoot/blend_position", Vector2.UP.rotated(direction))
			parent.animation_tree.set("parameters/Idle/blend_position", Vector2.UP.rotated(direction))
			parent.update_shadow(direction)

		# go to shoot animation
		if parent.animation_state != null:
			parent.animation_state.travel("Shoot")
			
		
		$ScriptedPlayer.play("shoot")
		
