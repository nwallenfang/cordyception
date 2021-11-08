tool
extends StaticBody2D

enum Version {
	GREEN, YELLOW, BLUE
	}

const GREEN_SPRITE := preload("res://World/Shrooms/shroom1.png")
const YELLOW_SPRITE := preload("res://World/Shrooms/shroom1_yellow.png")
const BLUE_SPRITE := preload("res://World/Shrooms/shroom1_blue.png")

export(Version) var color := Version.YELLOW setget set_version

func set_version(version) -> void:
	color = version
	match color:
		Version.GREEN:
			$Sprite.texture = GREEN_SPRITE
		Version.YELLOW:
			$Sprite.texture = YELLOW_SPRITE
		Version.BLUE:
			$Sprite.texture = BLUE_SPRITE
