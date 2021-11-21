extends AbstractState

export var SPEED_SLOW := 20000.0
export var SPEED_FAST := 50000.0
export var HOMING_SPEED := 10000.0
export var slow_time := 1.0
export var roll_time := 2.0

func _ready() -> void:
	RELATIVE_TRANSITION_CHANCE = 1
	parent = parent as RedAphid
	slow_time = (parent.get_node("SpinPlayer") as AnimationPlayer).get_animation("spin_right").length * 2

var direction: Vector2
var acc: Vector2
var speed: float

func process(delta, first_time_entering):
	parent = parent as RedAphid
	var player_global : Vector2 = GameStatus.CURRENT_PLAYER.global_position
	
	if first_time_entering:
		var scent_global : Vector2 = parent.line2D.points[1] + parent.global_position 
		if scent_global.distance_to(player_global) > 20.0:
			state_machine.transition_deferred("Idle")
			return
		parent.set_roll_area(true)
		direction = parent.global_position.direction_to(player_global)
		parent.set_facing_direction(direction)
		parent.play_start_roll()
		speed = SPEED_SLOW
		yield(get_tree().create_timer(slow_time), "timeout")
		speed = SPEED_FAST
		parent.play_speed_roll()
		yield(get_tree().create_timer(roll_time), "timeout")
		speed = SPEED_SLOW
		parent.play_stop_roll()
		yield(parent, "roll_stopped")
		parent.set_roll_area(false)
		state_machine.transition_deferred("Idle")
		return

	var homing_acc = parent.global_position.direction_to(player_global) * HOMING_SPEED
	acc = direction * speed + homing_acc
	parent.add_acceleration(acc)
