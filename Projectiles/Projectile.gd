extends SlideMover


const COLOR := false  # TODO
const SIZE := 16  # TODO
const IS_PIERCING := false  # whether or not to be destroyed when hitting something

onready var direction: Vector2 setget set_direction
onready var damage: int setget set_damage

func set_direction(new_dir: Vector2):
	direction = new_dir
	
func set_damage(new_damage: int):
	damage = new_damage

func _physics_process(delta: float) -> void:
	accelerate_and_move(direction, delta)

func _on_Hurtbox_area_entered(area: Area2D) -> void:
	# TODO check if area is a valid hitbox, (maybe it's guaranteed given the collision masks)
	if not IS_PIERCING:
		# TODO if there will be many projectiles instantiated at once and there 
		# are performance problems, don't free them immediately
		# google Pooling instead
		queue_free()  
	
	
	
