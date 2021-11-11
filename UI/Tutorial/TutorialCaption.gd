extends Node2D
class_name TutorialCaption

onready var tween := $Tween as Tween

func _ready() -> void:
	$Area2D.monitoring = true
	$Area2D.monitorable = true
	GameStatus.connect("input_device_changed", self, "on_input_device_changed")
	if GameStatus.CONTROLLER_USED:
		$SpriteC.modulate = Color.white
		$SpriteK.modulate = Color.transparent
	else:
		$SpriteC.modulate = Color.transparent
		$SpriteK.modulate = Color.white

func _on_Area2D_body_entered(body: Node) -> void:
	tween.interpolate_property(self, "modulate", Color.transparent, Color.white, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()

func _on_Area2D_body_exited(body: Node) -> void:
	tween.interpolate_property(self, "modulate", Color.white, Color.transparent, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()

func on_input_device_changed() -> void:
	if GameStatus.CONTROLLER_USED:
		tween.interpolate_property($SpriteC, "modulate", Color.transparent, Color.white, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
		tween.interpolate_property($SpriteK, "modulate", Color.white, Color.transparent, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	else:
		tween.interpolate_property($SpriteC, "modulate", Color.white, Color.transparent, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.interpolate_property($SpriteK, "modulate", Color.transparent, Color.white, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
	tween.start()
