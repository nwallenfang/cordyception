extends Node2D
class_name StagBeetle

var sprite_rotation := 0.0 setget set_rotation

func set_rotation(rot):
	rot = rad2deg(deg2rad(rot))
	$AnimatedSprite.rotation = deg2rad(rot)
	sprite_rotation = rot
	

func _ready():
	$StateMachine.start()
	$AnimatedSprite.play("idle")

func _process(delta):
	$StateMachine.process(delta)
