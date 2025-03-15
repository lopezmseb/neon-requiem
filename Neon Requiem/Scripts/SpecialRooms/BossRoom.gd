extends TileMap

func _notification(what):
	if(what == NOTIFICATION_PREDELETE):
		clear()
