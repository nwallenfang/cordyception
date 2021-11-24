extends TextureProgress


export var MAX_HEALTH: int = 200 setget set_max


onready var health := MAX_HEALTH setget set_health

var faded_out =  Color("00ffffff")
var faded_in = Color("ffffffff")
func _ready() -> void:
	self.modulate = faded_out

func set_max(new_max) -> void:
	MAX_HEALTH = new_max
	max_value = new_max
	set_health(new_max)

# TODO make invisible by default
func set_health(new_health) -> void:
	# health bar shouldn't be responsible for such logic checks but just to make
	# sure..
	new_health = min(new_health, MAX_HEALTH)
	
	if new_health < health:
		self.modulate = faded_in
		if $FadeTimer.is_stopped():
			# reset timer
			$FadeTimer.start()
		$FadeTimer.start()
	
	health = new_health
	self.value = health
	
	

	
func _on_FadeTimer_timeout() -> void:
	if $Tween.is_active():
		print("fadeout already happening")
		return
	$FadeTween.reset_all()
	$FadeTween.interpolate_property(self, "modulate", faded_in, faded_out, 1)
	$FadeTween.start()
