extends PhysicsMover
class_name Phoridae

export var fly_speed := 600.0
export var walk_speed := 400.0

onready var levitation_player := $LevitationPlayer as AnimationPlayer
onready var animation_player := $AnimationPlayer as AnimationPlayer
onready var healthbar := $Body/Healthbar

var aggressive := false
var flying := false

func _ready():
	$StateMachine.start()

const FLY_DUST = preload("res://Enemies/Phoridae/FlyDust.tscn")
func create_fly_dust() -> void:
	var dust = FLY_DUST.instance()
	GameStatus.CURRENT_YSORT.add_child(dust)
	dust.global_position = global_position
	dust.connect("animation_finished", dust, "queue_free")
	dust.playing = true

func set_facing_direction(direction: Vector2) -> void:
	$Body/Sprite.flip_h = direction.x < 0


func _process(delta: float) -> void:
	$Line2D.points[1] = $ScentRay.get_player_scent_position() - position
	$StateMachine.process(delta)
	accelerate_and_move(delta)


func _on_Detection_body_entered(body: Node) -> void:
	aggressive = true
