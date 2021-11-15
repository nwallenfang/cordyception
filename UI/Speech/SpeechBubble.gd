extends Node2D
class_name SpeechBubble

onready var text_node := $Origin/RichTextLabel
onready var text_bg := $Origin/ColorRect

export var CHAR_TIME := 0.04
export var MARGIN_OFFSET := 20
export var DEFAULT_WAIT := 3.0
export var arrow_pos := 0.8
export var arrow_reversed := true

func _ready() -> void:
	visible = false

const MIN_SIZE = Vector2(44, 44)
var bubble_size: Vector2 = MIN_SIZE setget set_bubble_size

func set_bubble_size(size: Vector2) -> void:
	size.x = max(MIN_SIZE.x, size.x)
	size.y = max(MIN_SIZE.y, size.y)
	bubble_size = size
	var offset := size - MIN_SIZE
	for element in [$Origin/CornerB, $Origin/CornerD, $Origin/SideD]:
		element.rect_position.x = 28 + offset.x
	for element in [$Origin/SideB, $Origin/SideC]:
		element.rect_size.x = 16 + offset.x
	for element in [$Origin/CornerC, $Origin/CornerD, $Origin/SideC]:
		element.rect_position.y = 28 + offset.y
	for element in [$Origin/SideA, $Origin/SideD]:
		element.rect_size.y = 16 + offset.y
	$Origin/ColorRect.rect_size = Vector2(36, 36) + offset
	$Origin/RichTextLabel.rect_size = Vector2(32, 32) + offset
	$Arrow.rect_position.y = 42 + offset.y
	$Arrow.rect_position.x = 4 + int((size.x - 24) * arrow_pos)
	$Arrow.flip_h = arrow_reversed

func set_text(lines, wait_time = DEFAULT_WAIT):
	if lines is String:
		lines = [lines]
	if wait_time == null:
		wait_time = DEFAULT_WAIT
	
	var text := ""
	var text_size := Vector2.ZERO
	
	for _line in lines:
		var line : String = _line as String
		text = text + "[center]" + line + "[/center]\n"
		
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
	
	set_bubble_size(text_size + Vector2(MARGIN_OFFSET, 2))
	
	text_node.bbcode_text = text
	
	# animation duration
	var duration = text_node.text.length() * CHAR_TIME
	
	# Animation
	$Tween.remove_all()
	$Tween.interpolate_property(text_node, "percent_visible", 0, 1, duration)
	$Tween.start()
#	$Tween.interpolate_property(text_bg, "margin_right", 3*BUBBLE_BORDER, text_size.x + 2 * MARGIN_OFFSET, duration)
#	for element in [$Origin/CornerB, $Origin/CornerD, $Origin/SideD]:
#		$Tween.interpolate_property(element, "rect_position", element.rect_position, element.rect_position + Vector2(text_size.x - 2*BUBBLE_BORDER, 0), duration)
#	for element in [$Origin/SideB, $Origin/SideC]:
#		$Tween.interpolate_property(element, "rect_size", element.rect_size, element.rect_size + Vector2(text_size.x - 2*BUBBLE_BORDER, 0), duration)
#	$Tween.interpolate_property($Origin, "position", Vector2.ZERO, Vector2(-text_size.x/2, 0), duration)

	
	# idea was to start sound from random position to make it less repetitive
	# sound is approx 11 secs 
	$SpeechSound.play(rand_range($SpeechSound.stream.loop_begin, $SpeechSound.stream.loop_end))

	visible = true

func _on_Tween_tween_all_completed() -> void:
	$SpeechSound.stop()
	$Timer.start()

func _on_Timer_timeout() -> void:
	visible = false
