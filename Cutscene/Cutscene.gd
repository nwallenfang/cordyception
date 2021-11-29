extends Node2D

var stop_y_value := -4200
var start_y_value := 1300
var movement := false

var animation_trigger_y_value := -4000
var spore_trigger_y_value := -2700

func _ready() -> void:
	$ParallaxBackground.scroll_offset.y = start_y_value
	if get_tree().current_scene == self:
		start_movement()

func _physics_process(delta: float) -> void:
	if movement:
		if $ParallaxBackground.scroll_offset.y > stop_y_value:
			$ParallaxBackground.scroll_offset.y -= 5
		else:
			last_spores()
		if $ParallaxBackground.scroll_offset.y < animation_trigger_y_value:
			start_animation()
		if $ParallaxBackground.scroll_offset.y < spore_trigger_y_value:
			start_spores()

var last_sent := false
func last_spores():
	if !last_sent:
		last_sent = true
		yield(get_tree().create_timer(2), "timeout")
		$ParallaxBackground/Foreground/SteinAmeise/LastSpores.emitting = true

func start_spores():
	$ParallaxBackground/AntAst/AstAmeise/Particles2D.emitting = true

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
		yield(get_tree().create_timer(7.2), "timeout")
		var tween := $ParallaxBackground/Foreground/SteinAmeise/GlowTween as Tween
		var glow := $ParallaxBackground/Foreground/SteinAmeise/GlowSprite as Sprite
		tween.interpolate_property(glow, "modulate", Color.transparent, Color.white, .5)
		tween.start()
		yield(tween, "tween_all_completed")
		tween.interpolate_property(glow, "modulate", Color.white, Color.transparent, .5)
		tween.start()

