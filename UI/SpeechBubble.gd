extends Node2D
class_name SpeechBubble

onready var text_node := $Origin/RichTextLabel
onready var text_bg := $Origin/ColorRect

export var CHAR_TIME := 0.04
export var MARGIN_OFFSET := 8
export var DEFAULT_WAIT := 3

func _ready() -> void:
	visible = false

func set_text(text, wait_time = DEFAULT_WAIT):
	if wait_time == null:
		wait_time = DEFAULT_WAIT

	$Timer.wait_time = wait_time
	$Timer.stop()
	
	text_node.bbcode_text = text
	
	# animation duration
	var duration = text_node.text.length() * CHAR_TIME
	
	# Set the size of the speech bubble
	var text_size = text_node.get_font("normal_font").get_string_size(text_node.text)
	text_node.margin_left = MARGIN_OFFSET
	text_node.margin_top = MARGIN_OFFSET
	text_node.margin_right = text_size.x + MARGIN_OFFSET
	
	# Animation
	$Tween.remove_all()
	$Tween.interpolate_property(text_node, "percent_visible", 0, 1, duration)
	$Tween.interpolate_property(text_bg, "margin_right", 0, text_size.x + 2 * MARGIN_OFFSET, duration)
	$Tween.interpolate_property($Origin, "position", Vector2.ZERO, Vector2(-text_size.x/2, 0), duration)
	$Tween.start()
	
	# idea was to start sound from random position to make it less repetitive
	# sound is approx 11 secs 
	$SpeechSound.play(rand_range($SpeechSound.stream.loop_begin, $SpeechSound.stream.loop_end))

	visible = true

func _on_Tween_tween_all_completed() -> void:
	$SpeechSound.stop()
	$Timer.start()

func _on_Timer_timeout() -> void:
	visible = false
