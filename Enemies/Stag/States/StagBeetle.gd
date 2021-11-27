extends Node2D
class_name StagBeetle

onready var origin := $Origin as Node2D
onready var sprite := $Origin/AnimatedSprite as AnimatedSprite
onready var state_machine := $StateMachine as StagStateMachine

var sprite_rotation := 0.0 setget set_rotation

func set_rotation(rot):
	rot = normalize_angle(rot)
	origin.rotation = deg2rad(rot)
	sprite_rotation = rot

func _ready():
	$StateMachine.start()
	play_animation("idle")

func _process(delta):
	$StateMachine.process(delta)

func play_animation(animation_name: String, start_at_zero: bool = true) -> void:
	sprite.play(animation_name)
	if start_at_zero:
		sprite.frame = 0

func get_animation_length(animation_name: String) -> float:
	var frames := sprite.frames
	var frame_count := frames.get_frame_count(animation_name)
	var animation_speed:= frames.get_animation_speed(animation_name)
	return float(frame_count) / animation_speed

func normalize_angle(degs: float) -> float:
	degs = rad2deg(deg2rad(degs))
	if degs > 180:
		degs -= 360
	elif degs < -180:
		degs += 360
	return degs
