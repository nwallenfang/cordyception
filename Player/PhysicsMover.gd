extends KinematicBody2D

class_name PhysicsMover

# doesn't have to be this value, it's just for readability
const EXPECTED_FPS = 60

export var FRICTION := 0.9
export var OLD_DEFAULT_ACC_STRENGTH := 3500

onready var velocity := Vector2.ZERO 
onready var acceleration := Vector2.ZERO 

func add_acceleration(var added_acc: Vector2):
	acceleration += added_acc

func accelerate_and_move(delta: float, acceleration_direction: Vector2 = Vector2.ZERO, acceleration_strength: float = OLD_DEFAULT_ACC_STRENGTH) -> void:
	var added_acc: Vector2
	if acceleration_direction.is_normalized():
		added_acc = acceleration_direction * acceleration_strength
	else:
		added_acc = acceleration_direction
		
	acceleration += added_acc
	velocity += acceleration * delta
	velocity = velocity * pow(FRICTION, delta * EXPECTED_FPS)
		
	execute_movement()
	acceleration = Vector2.ZERO 


func execute_movement() -> void:
	velocity = move_and_slide(velocity)
