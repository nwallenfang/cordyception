extends KinematicBody2D

class_name SlideMover

var velocity := Vector2.ZERO setget set_velocity, get_velocity

export var SPEED := 100
export var ACCELERATION := 450
export var FRICTION := 450

onready var speed := SPEED setget set_speed
onready var acceleration := ACCELERATION
onready var friction := FRICTION

func set_velocity(new_velocity: Vector2) -> void:
	velocity = new_velocity

func get_velocity() -> Vector2:
	return velocity
	
func reset_speed() -> void:
	speed = SPEED
	
func set_speed(new_speed: int) -> void:
	speed = new_speed


func accelerate_and_move(direction_vector: Vector2, delta: float) -> void:
	accelerate(direction_vector, delta)
	execute_movement()

func accelerate(direction_vector: Vector2, delta: float) -> void:
	if direction_vector != Vector2.ZERO:
		velocity = velocity.move_toward(direction_vector * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

func execute_movement() -> void:
	velocity = move_and_slide(velocity)
