extends PhysicsMover


func _ready():
	$StateMachine.start()

const FLY_DUST = preload("res://Enemies/Phoridae/FlyDust.tscn")
func create_fly_dust() -> void:
	var dust = FLY_DUST.instance()
	GameStatus.CURRENT_YSORT.add_child(dust)
	dust.global_position = global_position
	dust.connect("animation_finished", dust, "queue_free")
	dust.playing = true

func set_facing_direction(direction: Vector2) -> void:
	$Body/Sprite.flip_h = direction.x < 0


func _process(delta: float) -> void:
	$Line2D.points[1] = $ScentRay.get_player_scent_position() - position
	$StateMachine.process(delta)
	accelerate_and_move(delta)
