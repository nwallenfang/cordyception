extends Camera2D
class_name ScriptedCamera

export var default_zoom := 1.0
export var default_drag := 0.17
export var drag_deactivation_time := 1.0
export var drag_activation_time := 0.5

var on_player := true
var follow_target: Node2D = null
var following := false

var return_signal: String = ""

signal slide_finished(id)
signal zoom_finished(id)
signal back_at_player(id)
signal follow_target_reached(id)
signal fade_in_finished
signal fade_out_finished

func deactivate_drag():
	if drag_margin_left == 0:
		return
	$DragTween.remove_all()
	$DragTween.interpolate_property(self, "drag_margin_left", default_drag, 0, drag_deactivation_time)
	$DragTween.interpolate_property(self, "drag_margin_right", default_drag, 0, drag_deactivation_time)
	$DragTween.interpolate_property(self, "drag_margin_top", default_drag, 0, drag_deactivation_time)
	$DragTween.interpolate_property(self, "drag_margin_bottom", default_drag, 0, drag_deactivation_time)
	$DragTween.start()

func activate_drag():
	if drag_margin_left == default_drag:
		return
	$DragTween.remove_all()
	$DragTween.interpolate_property(self, "drag_margin_left", 0, default_drag, drag_activation_time)
	$DragTween.interpolate_property(self, "drag_margin_right", 0, default_drag, drag_activation_time)
	$DragTween.interpolate_property(self, "drag_margin_top", 0, default_drag, drag_activation_time)
	$DragTween.interpolate_property(self, "drag_margin_bottom", 0, default_drag, drag_activation_time)
	$DragTween.start()

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
	on_player = false
	GameStatus.CURRENT_CAM_REMOTE.update_position = false
	deactivate_drag()
	__slide_to_moveable(obj, time)

func slide_away_to(pos: Vector2, time: float = 2.0) -> void:
	on_player = false
	GameStatus.CURRENT_CAM_REMOTE.update_position = false
	deactivate_drag()
	__slide_to(pos, time)
	
func slide_away_to_then_return(pos: Vector2, time: float = 2.0) -> void:
	slide_away_to(pos, time)
	yield(self, "slide_finished")

func __slide_to(pos: Vector2, time: float = 2.0) -> void:
	$Tween.remove_all()
	$Tween.interpolate_property(self, "global_position", global_position, pos, time,Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()

var sliding_to_moveable := false
var moveable_own_old_position : Vector2
var moveable_target : Node2D = null
var moveable_current_position := 0.0
func __slide_to_moveable(obj: Node2D, time: float = 2.0) -> void:
	sliding_to_moveable = true
	moveable_own_old_position = global_position
	moveable_target = obj
	$Tween.remove_all()
	$Tween.interpolate_property(self, "moveable_current_position", 0.0, 1.0, time)
	$Tween.start()
	

func back_to_player(time: float = 2.0) -> void:
	stop_following()
	on_player = true
	__slide_to_moveable(GameStatus.CURRENT_PLAYER, time)

func flash(return_duration:=0.6):
	$CanvasLayer/ColorRect.visible = true
	var return_color = Color($CanvasLayer/ColorRect.color)
	$FlashTween.remove_all()
	$FlashTween.interpolate_property($CanvasLayer/ColorRect, "color", Color(1, 1, 1, 1), Color(1, 1, 1, 0), return_duration)
	$FlashTween.start()
	
func fade_out(duration:=0.6):
	$CanvasLayer/ColorRect.visible = true
	$FadeOutTween.interpolate_property($CanvasLayer/ColorRect, "color", Color(0, 0, 0, 0), Color.black, duration)
	$FadeOutTween.start()
	
func fade_in(duration:=0.6):
	$CanvasLayer/ColorRect.visible = true
	var return_color = Color($CanvasLayer/ColorRect.color)
	$FadeInTween.interpolate_property($CanvasLayer/ColorRect, "color", Color.black, Color(0, 0, 0, 0), duration)
	$FadeInTween.start()


func _on_Tween_tween_all_completed() -> void:
	sliding_to_moveable = false
	if on_player:
		GameStatus.CURRENT_CAM_REMOTE.update_position = true
		activate_drag()
		emit_signal("back_at_player", return_signal)
	if follow_target != null:
		following = true
		emit_signal("follow_target_reached", return_signal)
	emit_signal("slide_finished", return_signal)

func _process(delta: float) -> void:
	if sliding_to_moveable:
		global_position = (1 - moveable_current_position) * moveable_own_old_position + moveable_current_position * moveable_target.global_position
	elif following:
		global_position = follow_target.global_position

func _on_ZoomTween_tween_all_completed() -> void:
	emit_signal("zoom_finished", return_signal)

func _on_FlashTween_tween_all_completed() -> void:
	$CanvasLayer/ColorRect.visible = false
	
func _on_FadeInTween_tween_all_completed() -> void:
	$CanvasLayer/ColorRect.visible = false
	emit_signal("fade_in_finished")


func _on_FadeOutTween_tween_all_completed() -> void:
	emit_signal("fade_out_finished")
