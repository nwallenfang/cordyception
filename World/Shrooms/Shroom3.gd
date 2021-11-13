tool
extends StaticBody2D

enum ShroomColor {
	GREEN, VIOLET, YELLOW
}

const GREEN_SPRITE := preload("res://World/Shrooms/Pilz_03_Green.png")
const YELLOW_SPRITE := preload("res://World/Shrooms/Pilz_03_Yellow.png")
const VIOLET_SPRITE := preload("res://World/Shrooms/Pilz_03_Violet.png")

const GREEN_CAP := preload("res://World/Shrooms/Pilz_03_GreenCap.png")
const YELLOW_CAP := preload("res://World/Shrooms/Pilz_03_YellowCap.png")
const VIOLET_CAP := preload("res://World/Shrooms/Pilz_03_VioletCap.png")

onready var sprite := $Sprite
onready var cap := $Cap
onready var particles := $Particles2D
export(ShroomColor) var color : int setget set_color

func _ready() -> void:
	set_color(color)

func set_color(new_color) -> void:
	color = new_color
	if sprite != null:
		match color:
			ShroomColor.GREEN:
				sprite.texture = GREEN_SPRITE
				cap.texture = GREEN_CAP
				particles.modulate = Color.greenyellow
			ShroomColor.YELLOW:
				sprite.texture = YELLOW_SPRITE
				cap.texture = YELLOW_CAP
				particles.modulate = Color.yellow
			ShroomColor.VIOLET:
				sprite.texture = VIOLET_SPRITE
				cap.texture = VIOLET_CAP
				particles.modulate = Color.purple
