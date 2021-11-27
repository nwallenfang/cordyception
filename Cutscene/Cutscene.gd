extends Node2D

var stop_y_value := -4200
var start_y_value := 1300
var movement := false

var animation_trigger_y_value := -4000

func _ready() -> void:
	$ParallaxBackground.scroll_offset.y = start_y_value
	if get_tree().current_scene == self:
		start_movement()

func _physics_process(delta: float) -> void:
	if movement:
		if $ParallaxBackground.scroll_offset.y > stop_y_value:
			$ParallaxBackground.scroll_offset.y -= 5
		if $ParallaxBackground.scroll_offset.y < animation_trigger_y_value:
			start_animation()

func start_movement():
	movement = true
	yield(get_tree().create_timer(6.5), "timeout")
	$AudioStreamPlayer.play()

func start_game():
	get_tree().change_scene("res://Levels/Act1.tscn")

var animation_started := false
func start_animation():
	if !animation_started:
		animation_started = true
		$AnimationPlayer.play("stone_animation")

