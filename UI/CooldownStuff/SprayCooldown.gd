tool
extends Control

export(float, 0.0, 1.0) var blend: float = 1.0 setget set_blend
const HEIGHT := 27
const DOWN_SPEED = 0.3 # should be bound to length of spray sound
const UP_SPEED = 3
var spraying = false

func set_blend(_blend: float) -> void:
	if _blend == 1.0 or _blend == 0.0:
		print("blend ", _blend)
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
	GameStatus.connect("start_spray", self, "start_spray")
	GameStatus.connect("stop_spray", self, "stop_spray")
	
func start_spray():
	if spraying:
		return
	spraying = true
	var duration = blend / DOWN_SPEED
	print("activate down")
	$UpTween.stop_all()
	$DownTween.interpolate_property(self, "blend", blend, 0, duration)
	$DownTween.start()
	
func stop_spray():
	if not spraying:
		return
	$DownTween.stop_all()
	var duration = blend / UP_SPEED
	print("activate up")
	$UpTween.interpolate_property(self, "blend", blend, 1, duration)
	$UpTween.start()	
	spraying = false
	

func input_device_changed():
	$Controller.visible = not $Controller.visible
	$Keyboard.visible = not $Keyboard.visible
