extends Timer

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		stop()
