extends KinematicBody2D
 
 

const IS_PIERCING := false  # whether or not to be destroyed when hitting something
export var COLOR := false  # TODO
export var SIZE := 16  # TODO
export var SPEED := 20
 
onready var direction: Vector2 setget set_direction
onready var damage: int setget set_damage
onready var velocity := SPEED * direction


func _ready():
	$AnimationPlayer.play("active")
 
func set_direction(new_dir: Vector2):
	direction = new_dir
	velocity = SPEED * direction
	
func set_damage(new_damage: int):
	damage = new_damage
 
func _physics_process(delta: float) -> void:
	var collision := move_and_collide(velocity)
 
	if collision:
		if collision.collider is StaticBody2D:
			# collided with obstacle or level boundary
			queue_free()
		# collided with something else
		# print(collision.collider)
	
func _on_Hitbox_area_entered(area: Area2D) -> void:
	print(area)
	# TODO check if area is a valid hitbox, (maybe it's guaranteed given the collision masks)
	if not IS_PIERCING:
		# TODO if there will be many projectiles instantiated at once and there 
		# are performance problems, don't free them immediately
		# google Pooling instead
		queue_free()  
