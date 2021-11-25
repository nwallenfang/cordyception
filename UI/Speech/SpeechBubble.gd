extends Node2D
class_name SpeechBubble

onready var text_node := $Origin/RichTextLabel as RichTextLabel
onready var text_bg := $Origin/ColorRect as ColorRect
onready var sideA := $Origin/SideA as TextureRect
onready var sideB := $Origin/SideB as TextureRect
onready var sideC := $Origin/SideC as TextureRect
onready var sideD := $Origin/SideD as TextureRect
onready var cornerA := $Origin/CornerA as TextureRect
onready var cornerB := $Origin/CornerB as TextureRect
onready var cornerC := $Origin/CornerC as TextureRect
onready var cornerD := $Origin/CornerD as TextureRect
onready var arrow := $Origin/Arrow as TextureRect
onready var origin := $Origin as Node2D

export var CHAR_TIME := 0.04
export var MARGIN_OFFSET := 10
export var DEFAULT_WAIT := 3.0
export var arrow_pos := 0.8
export var arrow_reversed_h := false
export var arrow_reversed_v := false
export var center := false

signal dialog_completed
signal writing_completed

func set_nodes() -> void:
	text_node = $Origin/RichTextLabel as RichTextLabel
	text_bg = $Origin/ColorRect as ColorRect
	sideA = $Origin/SideA as TextureRect
	sideB = $Origin/SideB as TextureRect
	sideC = $Origin/SideC as TextureRect
	sideD = $Origin/SideD as TextureRect
	cornerA = $Origin/CornerA as TextureRect
	cornerB = $Origin/CornerB as TextureRect
	cornerC = $Origin/CornerC as TextureRect
	cornerD = $Origin/CornerD as TextureRect
	arrow = $Origin/Arrow as TextureRect
	origin = $Origin as Node2D

var is_ready := false
func _ready() -> void:
	set_nodes()
	visible = false
	is_ready = true

const MIN_SIZE = Vector2(44, 44)
export var bubble_size: Vector2 = Vector2(44, 44) setget set_bubble_size

func set_bubble_size(size: Vector2) -> void:
	if !is_ready:
		return

	size.x = max(MIN_SIZE.x, size.x)
	size.y = max(MIN_SIZE.y, size.y)
	bubble_size = size
	
	var offset := size - MIN_SIZE
	for element in [cornerB, cornerD, sideD]:
		element.rect_position.x = 28 + offset.x
	for element in [sideB, sideC]:
		element.rect_size.x = 16 + offset.x
	for element in [cornerC, cornerD, sideC]:
		element.rect_position.y = 28 + offset.y
	for element in [sideA, sideD]:
		element.rect_size.y = 16 + offset.y
	text_bg.rect_size = Vector2(36, 36) + offset
	text_node.rect_size = Vector2(32, 26) + offset# + Vector2(28, 0)
	if !center:
		text_node.rect_size = Vector2(2000, 400)
	arrow.flip_h = arrow_reversed_h
	arrow.flip_v = arrow_reversed_v
	if arrow_reversed_v:
		arrow.rect_position.y = -14
	else:
		arrow.rect_position.y = 42 + offset.y
	arrow.rect_position.x = 4 + int((size.x - 24) * arrow_pos)
	
	var flip_offset := Vector2(0 if !arrow_reversed_h else -16, 0 if arrow_reversed_v else -16)
	
	origin.position = - arrow.rect_position + flip_offset


func set_text(lines, wait_time = DEFAULT_WAIT):
	if lines is String:
		lines = [lines]
	if wait_time == null:
		wait_time = DEFAULT_WAIT
	
	var text := ""
	var text_size := Vector2.ZERO
	
	for _line in lines:
		var line : String = _line as String
		if center:
			text = text + "[center]" + line + "[/center]\n"
		else:
			text = text + line + "\n"
		
		var line_without_tags = ""
		var splitA := line.split("[")
		line_without_tags += splitA[0]
		for i in range(1, splitA.size()):
			line_without_tags += splitA[i].split("]")[1]
			
		var line_size = text_node.get_font("normal_font").get_string_size(line_without_tags)
		if line_size.x > text_size.x:
			text_size.x = line_size.x
		text_size.y += 34
		
	$Timer.wait_time = wait_time
	$Timer.stop()
	
	#set_bubble_size(text_size + Vector2(MARGIN_OFFSET, 2))
	
	text_node.bbcode_text = text
	
	# animation duration
	var duration = text_node.text.length() * CHAR_TIME
	
	# Animation
	$Tween.remove_all()
	$Tween.interpolate_property(text_node, "percent_visible", 0, 1, duration)
	$Tween.interpolate_property(self, "bubble_size", Vector2(2*MARGIN_OFFSET + 4, 0), text_size + Vector2(2*MARGIN_OFFSET, 0), duration)
	$Tween.start()
	
	# idea was to start sound from random position to make it less repetitive
	# sound is approx 11 secs 
	$SpeechSound.play(rand_range($SpeechSound.stream.loop_begin, $SpeechSound.stream.loop_end))

	yield(get_tree().create_timer(.1), "timeout")
	set_deferred("visible", true)
	
func say(lines, wait_time = DEFAULT_WAIT):
	set_text(lines, wait_time)
	yield(self, "dialog_completed")
	
# for interruptions:
func stop_and_blend(blend_time:=0.0):
	$SpeechSound.stop()
	$Timer.stop()
	$Tween.stop_all()
	$Tween.remove_all()
	if blend_time == 0:
		visible = false
		return
	var target_color = Color(modulate.r, modulate.b, modulate.g, 0)
	$BlendTween.interpolate_property(self, "modulate", self.modulate, target_color, blend_time)
	$BlendTween.start()

func _on_Tween_tween_all_completed() -> void:
	$SpeechSound.stop()
	$Timer.start()
	emit_signal("writing_completed")

func _on_Timer_timeout() -> void:
	text_node.percent_visible = 0
	text_node.bbcode_text = ""
	set_bubble_size(Vector2.ZERO)
	if visible:
		visible = false
		emit_signal("dialog_completed")
