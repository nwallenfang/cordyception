tool
extends Control

export(float, 0.0, 1.0) var blend: float = 1.0 setget set_blend
const HEIGHT := 27

func set_blend(_blend: float) -> void:
	blend = _blend
	if blend == 0.0:
		blend_zero()
	elif blend == 1.0:
		blend_one()
	$FullControl.rect_size.y = int(blend * HEIGHT)
	$Particles2D.restart()

func blend_zero():
	$AnimationPlayer.play("zero")

func blend_one():
	$AnimationPlayer.play("one")

func _ready() -> void:
	blend_one()
	GameStatus.connect("input_device_changed", self, "input_device_changed")

func input_device_changed():
	$Controller.visible = GameStatus.CONTROLLER_USED
	$Keyboard.visible = not GameStatus.CONTROLLER_USED
