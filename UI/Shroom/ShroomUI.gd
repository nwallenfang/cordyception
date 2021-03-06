extends Control
class_name Cordy

signal speech_done

var growth_phase := 0
func grow_first():
	growth_phase = 1
	$Growth.visible = true
	$Growth.playing = true
	$Growth.frame = 0
	$Growth.play("FirstPhase")
	
func grow_second():
	growth_phase = 2
	$Growth.visible = true
	$Growth.playing = true
	$Growth.frame = 0
	$Growth.play("SecondPhase")

func show():
	$Body.visible = true
	$Eyes.visible = true
	$Mouth.visible = true
	$Sparkle.visible = true
	$Growth.visible = false

func _on_Growth_animation_finished() -> void:
	if growth_phase == 2:
		show()
		
# int for currently talking bubbles
# 1 = left
# 2 = right
# 4 = bottom
var talking_bubbles : int = 0 setget set_talking_bubbles

func set_talking_bubbles(new: int) -> void:
	talking_bubbles = new
	$Mouth.playing = false if talking_bubbles == 0 else true

func is_left_talking() -> bool:
	return talking_bubbles % 2 == 1

func is_right_talking() -> bool:
	return (talking_bubbles % 4) / 2 == 1

func is_bottom_talking() -> bool:
	return talking_bubbles / 4 == 1

func _on_SpeechBubbleLeft_writing_completed() -> void:
	self.talking_bubbles = talking_bubbles - 1

func _on_SpeechBubbleRight_writing_completed() -> void:
	self.talking_bubbles = talking_bubbles - 2

func _on_SpeechBubbleBottom_writing_completed() -> void:
	self.talking_bubbles = talking_bubbles - 4

func say_left(text: String, duration: float = -1) -> bool:
	if $SpeechBubbleLeft.visible:
		return false
	else:
		if duration == -1: # no duration parameter
			$SpeechBubbleLeft.set_text(text)
		else:
			$SpeechBubbleLeft.set_text(text, duration)
		self.talking_bubbles = talking_bubbles + 1
		return true

func say_right(text: String, duration: float = -1) -> bool:
	if $SpeechBubbleRight.visible:
		return false
	else:
		if duration == -1: # no duration parameter
			$SpeechBubbleRight.set_text(text)
		else:
			$SpeechBubbleRight.set_text(text, duration)
		self.talking_bubbles = talking_bubbles + 2
		return true

func say_bottom(text: String, duration: float = -1) -> bool:
	if $SpeechBubbleBottom.visible:
		return false
	else:
		if duration == -1: # no duration parameter
			$SpeechBubbleBottom.set_text(text)
		else:
			$SpeechBubbleBottom.set_text(text, duration)
		self.talking_bubbles = talking_bubbles + 4
		return true

func say(text: String, duration: float = -1) -> void:
	var try := say_left(text, duration)
	if !try:
		try = say_bottom(text, duration)
	if !try:
		try = say_right(text, duration)

const MOOD_ANGRY = preload("res://UI/Shroom/Mood ANGRY.png")
const MOOD_BORED = preload("res://UI/Shroom/Mood BORED.png")
const MOOD_IDLE = preload("res://UI/Shroom/Mood IDLE.png")
const MOOD_HAPPY = preload("res://UI/Shroom/Mood HAPPY.png")
func set_eyes(mood_string: String):
	var mood
	match(mood_string):
		"angry":
			mood = MOOD_ANGRY
		"bored":
			mood = MOOD_BORED
		"idle":
			mood = MOOD_IDLE
		"happy":
			mood = MOOD_HAPPY
	$Eyes.texture = mood


func _on_SpeechBubbleLeft_dialog_completed() -> void:
	emit_signal("speech_done")


func _on_SpeechBubbleRight_dialog_completed() -> void:
	emit_signal("speech_done")


func _on_SpeechBubbleBottom_dialog_completed() -> void:
	emit_signal("speech_done")
