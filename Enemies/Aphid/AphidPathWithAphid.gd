extends YSort

func _ready() -> void:
	$Aphid.connect("tree_exiting", self, "queue_free")
