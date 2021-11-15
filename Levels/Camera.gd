extends Camera2D
class_name ScriptedCamera

export var default_zoom := 1.0

var on_player := true
var follow_target: Node2D = null
var following := false

signal slide_finished
signal zoom_finished
signal back_at_player
signal follow_target_reached

func zoom_back(time: float = 2.0):
	zoom(default_zoom, time)

func zoom(target_zoom: float, time: float = 2.0) -> void:
	$ZoomTween.interpolate_property(self, "zoom", zoom, Vector2(target_zoom, target_zoom), time)
	$ZoomTween.start()

func follow(obj: Node2D, time: float = 2.0) -> void:
	slide_to_object(obj, time)
	follow_target = obj

func stop_following() -> void:
	following = false
	follow_target = null

func slide_to_object(obj: Node2D, time: float = 2.0) -> void:
	slide_away_to(obj.global_position, time)

func print_pos():
	print("f ", global_position)

func slide_away_to(pos: Vector2, time: float = 2.0) -> void:
	on_player = false
	GameStatus.CURRENT_CAM_REMOTE.update_position = false
	var prev_position = global_position
	print("pre ", global_position)
	# instead of disabling drag margin tween towards 0.0
	drag_margin_h_enabled = false
	drag_margin_v_enabled = false
	print("post ", global_position)
#	__slide_to(pos, time)

func __slide_to(pos: Vector2, time: float = 2.0) -> void:
#	print(pos)
#	print("---------")
#	print(global_position)
	$Tween.remove_all()
	$Tween.interpolate_property(self, "global_position", global_position, pos, time,Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()

func back_to_player(time: float = 2.0) -> void:
	on_player = true
	__slide_to(GameStatus.CURRENT_PLAYER.global_position, time)

func _on_Tween_tween_all_completed() -> void:
	emit_signal("slide_finished")
	if on_player:
		GameStatus.CURRENT_CAM_REMOTE.update_position = true
		drag_margin_h_enabled = true
		drag_margin_v_enabled = true
		emit_signal("back_at_player")
	if follow_target != null:
		following = true
		emit_signal("follow_target_reached")

func _process(delta: float) -> void:
	if following:
		global_position = follow_target.global_position

func _on_ZoomTween_tween_all_completed() -> void:
	emit_signal("zoom_finished")
