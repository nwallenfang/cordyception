extends AbstractState

func _ready() -> void:
	RELATIVE_TRANSITION_CHANCE = 0

const PROJECTILE = preload("res://Enemies/Phoridae/PhoridaeProjectile.tscn")
func process(delta, first_time_entering):
	parent = parent as Phoridae
	if first_time_entering
