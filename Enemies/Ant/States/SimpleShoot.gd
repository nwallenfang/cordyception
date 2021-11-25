extends AbstractState

func _ready() -> void:
	RELATIVE_TRANSITION_CHANCE = 0


func __shoot_single():
	$EnemyProjectileSpawner.create_projectile(direction)

func __reset():
	parent.animation_state.travel("Idle")


func start_shooting_single_projectile(target_pos: Vector2):  # outside of state machine :)
	$EnemyProjectileSpawner.global_position = parent.get_node("Head").global_position
	direction = ($EnemyProjectileSpawner.global_position - target_pos).angle() - PI/2
	parent.animation_tree.set("parameters/Shoot/blend_position", Vector2.UP.rotated(direction))
	parent.animation_tree.set("parameters/Idle/blend_position", Vector2.UP.rotated(direction))
	parent.animation_state.travel("Shoot")
	$ScriptedPlayer.play("shoot_single")


var direction: float # will be set from process
func process(delta: float, first_time_entering: bool):
	# for now either shoot a cone in the player direction or shoot radial
	if first_time_entering:
		var line2d = parent.get_node("Line2D")
		direction = line2d.points[1].angle() + PI/2
	
		if parent.animation_tree != null:
			parent.animation_tree.set("parameters/Idle/blend_position", Vector2.UP.rotated(direction))
			parent.animation_tree.set("parameters/Shoot/blend_position", Vector2.UP.rotated(direction))

		# go to shoot animation
		if parent.animation_state != null:
			parent.animation_state.travel("Shoot")
		
		$ScriptedPlayer.play("shoot_single")
	else:
		pass
		
	# shooting stuff could be depending on distance to player..
	# if too far from the player, don't shoot at all but enter another state instead
