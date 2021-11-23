extends AbstractState

export(Curve) var fly_curve: Curve
var fly_curve_index := 0.0
export var travel_time := 0.5
export var fly_time := 2.0
export var wait_time := 0.5
var throw_target = null
var dust_created := true

func _ready() -> void:
	RELATIVE_TRANSITION_CHANCE = 0

func process(delta, first_time_entering):
	parent = parent as RedAphid

	if first_time_entering:
		throw_target = GameStatus.CURRENT_PLAYER as Player
		$Tween.interpolate_property(parent, "global_position", parent.global_position, parent.throw_origin.global_position, travel_time)
		$Tween.start()
		parent.play_walk_animation(parent.global_position.direction_to(parent.throw_origin.global_position))
		yield($Tween, "tween_all_completed")
		parent.emit_signal("ready_to_launch")
		var target_position = throw_target.global_position as Vector2
		$Tween.reset_all()
		$Tween.interpolate_property(parent, "global_position", parent.global_position, target_position, fly_time)
		$Tween.interpolate_property(self, "fly_curve_index", 0.0, 1.0, fly_time)
		$Tween.start()
		dust_created = false # for launch
		var throw_direction = parent.global_position.direction_to(target_position)
		parent.set_facing_direction(throw_direction)
		parent.play_walk_animation(Vector2.ZERO)
		yield(get_tree().create_timer(fly_time/2), "timeout") # only for impact dust
		dust_created = false
		yield($Tween, "tween_all_completed")
		state_machine.set_attack_behaviour()
		yield(get_tree().create_timer(wait_time), "timeout")
		state_machine.transition_deferred("Idle")

	parent.get_node("Sprite").position.y = - fly_curve.interpolate_baked(fly_curve_index)
	if fly_curve.interpolate_baked(fly_curve_index) < 2 and !dust_created:
		parent.create_impact_dust()
		dust_created = true
