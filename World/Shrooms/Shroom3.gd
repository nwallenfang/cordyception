tool
extends StaticBody2D

enum ShroomColor {
	GREEN, VIOLET, YELLOW
}

const GREEN_SPRITE := preload("res://World/Shrooms/Pilz_03_Green.png")
const YELLOW_SPRITE := preload("res://World/Shrooms/Pilz_03_Yellow.png")
const VIOLET_SPRITE := preload("res://World/Shrooms/Pilz_03_Violet.png")

onready var sprite := $Sprite
export(ShroomColor) var color : int setget set_color

func _ready() -> void:
	set_color(color)

func set_color(new_color) -> void:
	color = new_color
	if sprite != null:
		match color:
			ShroomColor.GREEN:
				sprite.texture = GREEN_SPRITE
			ShroomColor.YELLOW:
				sprite.texture = YELLOW_SPRITE
			ShroomColor.VIOLET:
				sprite.texture = VIOLET_SPRITE
