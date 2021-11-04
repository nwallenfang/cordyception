extends Node2D
class_name Projectile
 

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
	self.position += delta * velocity

func _on_Hitbox_area_entered(area: Area2D) -> void:	
	# TODO check if area is a valid hitbox, (maybe it's guaranteed given the collision masks)
	if not IS_PIERCING:
		# TODO if there will be many projectiles instantiated at once and there 
		# are performance problems, don't free them immediately
		# google Pooling instead
		self.velocity = Vector2.ZERO
		$AnimationPlayer.play("collision") 


func fly_animation():
	$AnimationPlayer.play("fly")


func _on_Hitbox_body_entered(body: Node) -> void:
	# Projectile hit a wall
	self.velocity = Vector2.ZERO
	$AnimationPlayer.play("collision")
