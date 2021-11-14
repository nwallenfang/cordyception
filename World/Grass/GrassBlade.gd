extends StaticBody2D
class_name GrassBlade

onready var mat := $Sprite.material as Material
onready var area := $Area2D as Area2D
onready var tween := $Tween as Tween
onready var second_tween := $Tween2 as Tween

export var TILT_SCALE := 700.0
export var OFFSET_SCALE := 0.7

var old_min
var old_scale
var old_speed
var old_offset

func _ready() -> void:
	area.connect("body_entered", self, "_on_Area2D_body_entered")
	area.connect("body_exited", self, "_on_Area2D_body_exited")
	tween.connect("tween_all_completed", self, "_on_Tween_tween_all_completed")
	mat.set("shader_param/offset", (global_position.x / 100.0) * OFFSET_SCALE)
	old_min = mat.get("shader_param/minStrength")
	old_scale = mat.get("shader_param/strengthScale")
	old_speed = mat.get("shader_param/speed")
	old_offset = mat.get("shader_param/offset")

var target: Node2D = null
var almost_target: Node2D = null
var mindist := 35.0
var maxdist := 200.0
var distdiff := maxdist - mindist

func get_target_dist() -> float:
	return target.global_position.distance_to(area.global_position)

func get_target_distx() -> float:
	return target.global_position.x - area.global_position.x

func _on_Area2D_body_entered(body: Node) -> void:
	almost_target = body as Node2D
	tween.interpolate_property(mat, "shader_param/minStrength", 0.05, 0.0, 0.2)
	tween.start()

func _on_Area2D_body_exited(body: Node) -> void:
	target = null
	almost_target = null
	tween.remove_all()
	tween.interpolate_property(mat, "shader_param/minStrength", 0.05, 0.0, 0.2)
	tween.start()

func tilt_value_normalized() -> float:
	var dist := clamp(get_target_dist(), mindist, maxdist)
	var normdist := (dist - mindist) / distdiff
	return - sign(get_target_distx()) * (1.0 - normdist)

# simple interpolation
func interpolate(A: float, B: float, t: float) -> float:
	return A + (B - A) * t

func _physics_process(delta: float) -> void:
	if target != null:
		var target_scale := tilt_value_normalized() * TILT_SCALE
		var previous_scale : float = mat.get("shader_param/strengthScale")
		mat.set("shader_param/strengthScale", int(interpolate(previous_scale, target_scale, 0.08)))

func _on_Tween_tween_all_completed() -> void:
	if almost_target:
		target = almost_target
		almost_target = null
		mat.set("shader_param/speed", 0)
		mat.set("shader_param/offset", 0.8)
		mat.set("shader_param/minStrength", 0.05)
		mat.set("shader_param/strengthScale", 0.0)
	else:
		mat.set("shader_param/speed", old_speed)
		mat.set("shader_param/offset", old_offset)
		mat.set("shader_param/strengthScale", old_scale)
		$Tween2.interpolate_property(mat, "shader_param/minStrength", 0, 0.05, .2)
		$Tween2.start()
